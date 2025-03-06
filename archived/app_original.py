import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pydeck as pdk
from datetime import datetime, timedelta
import os
import json
import logging
import logging.handlers
from pyspark.sql import SparkSession
import pyspark.sql.functions as F
from dotenv import load_dotenv
from delta import *

# Load environment variables
load_dotenv()

# Configure logging
LOG_DIR = os.getenv('LOG_DIR', '/var/log/nycbs/streamlit')
FALLBACK_LOG_DIR = os.path.join(os.getenv('HOME', '/home/aldamiz'), '.streamlit/logs')
LOG_FILE = None  # Will be set dynamically
ERROR_LOG_FILE = None  # Will be set dynamically

class JsonFormatter(logging.Formatter):
    """Custom JSON formatter for logging"""
    def format(self, record):
        log_obj = {
            'timestamp': datetime.utcnow().isoformat(),
            'app': 'streamlit-dashboard',
            'level': record.levelname,
            'message': record.getMessage(),
            'user': os.getenv('NB_USER', 'unknown'),
            'container': os.getenv('HOSTNAME', 'unknown'),
            'session_id': getattr(record, 'session_id', 'unknown'),
            'page': getattr(record, 'page', 'unknown'),
            'event_category': getattr(record, 'event_category', 'general'),
            'component': getattr(record, 'component', 'unknown'),
            'duration_ms': getattr(record, 'duration_ms', None),
            'data_size': getattr(record, 'data_size', None),
            'cache_hit': getattr(record, 'cache_hit', None),
            'error_type': getattr(record, 'error_type', None),
            'error_details': getattr(record, 'error_details', None)
        }
        # Remove None values
        return json.dumps({k: v for k, v in log_obj.items() if v is not None})

def try_create_log_structure(base_dir):
    """Try to create and verify log directory structure"""
    try:
        # Create directories
        info_dir = os.path.join(base_dir, 'info')
        error_dir = os.path.join(base_dir, 'error')
        os.makedirs(info_dir, exist_ok=True)
        os.makedirs(error_dir, exist_ok=True)
        
        # Create log files
        info_log = os.path.join(info_dir, 'streamlit.log')
        error_log = os.path.join(error_dir, 'streamlit.log')
        
        for log_file in [info_log, error_log]:
            if not os.path.exists(log_file):
                with open(log_file, 'a') as f:
                    f.write('')
                os.chmod(log_file, 0o660)
        
        # Verify we can write to both files
        for log_file in [info_log, error_log]:
            with open(log_file, 'a') as f:
                f.write('')
        
        return info_log, error_log
    except Exception as e:
        print(f"Failed to set up logs in {base_dir}: {str(e)}")
        return None, None

def ensure_log_directories():
    """Ensure log directories exist with proper permissions and fallback"""
    global LOG_FILE, ERROR_LOG_FILE
    
    # Try primary location first
    info_log, error_log = try_create_log_structure(LOG_DIR)
    
    # If primary fails, try fallback location
    if info_log is None:
        print(f"Primary log location {LOG_DIR} failed, trying fallback {FALLBACK_LOG_DIR}")
        info_log, error_log = try_create_log_structure(FALLBACK_LOG_DIR)
        
        if info_log is None:
            print("Failed to create log files in both primary and fallback locations")
            return False
    
    # Update global log file paths
    LOG_FILE = info_log
    ERROR_LOG_FILE = error_log
    print(f"Using log files: {LOG_FILE} and {ERROR_LOG_FILE}")
    return True

def setup_logging():
    """Configure logging to file and logstash"""
    logger = logging.getLogger('streamlit_logger')
    
    # Clear any existing handlers to prevent duplicates
    logger.handlers = []
    
    logger.setLevel(logging.INFO)
    
    # Ensure log directories exist and are writable
    if not ensure_log_directories():
        print("Falling back to stderr logging")
        logging.basicConfig(level=logging.INFO)
        return logger
    
    try:
        # Info file handler with rotation
        info_handler = logging.handlers.RotatingFileHandler(
            LOG_FILE,
            maxBytes=10485760,  # 10MB
            backupCount=5
        )
        info_handler.setLevel(logging.INFO)
        info_handler.setFormatter(JsonFormatter())
        
        # Error file handler with rotation
        error_handler = logging.handlers.RotatingFileHandler(
            ERROR_LOG_FILE,
            maxBytes=10485760,  # 10MB
            backupCount=5
        )
        error_handler.setLevel(logging.ERROR)
        error_handler.setFormatter(JsonFormatter())
        
        # Add handlers
        logger.addHandler(info_handler)
        logger.addHandler(error_handler)
        
    except Exception as e:
        print(f"Warning: Could not set up log handlers: {str(e)}")
        # Fallback to stderr if logging setup fails
        logging.basicConfig(level=logging.INFO)
    
    return logger

def log_event(logger, event_category, message, **kwargs):
    """Helper function to log events with consistent structure"""
    extra = {
        'session_id': st.session_state.get('session_id', 'unknown'),
        'page': st.session_state.get('current_page', 'unknown'),
        'event_category': event_category,
        **kwargs
    }
    logger.info(message, extra=extra)

# Initialize logger
logger = setup_logging()

# Initialize Spark Session with robust configuration
def create_spark_session():
    """Create a Spark session using central configuration"""
    try:
        # Use configuration from spark-defaults.conf
        spark = (SparkSession.builder
                .appName("NYC Bike Share Dashboard")
                .getOrCreate())
        
        # Test connection by running a simple query
        spark.sql("SELECT 1").collect()
        return spark
    except Exception as e:
        log_event(logger, 'error',
                 "Failed to create Spark session",
                 component='spark_session',
                 error_type=type(e).__name__,
                 error_details=str(e))
        raise RuntimeError(f"Failed to initialize Spark: {str(e)}")

# Initialize Spark session
try:
    spark = create_spark_session()
except Exception as e:
    st.error("Failed to initialize Spark session. Please try again later.")
    st.stop()

# Data paths
DATA_DIR = os.getenv('DATA_DIR', '/home/aldamiz/data')
GOLD_PATH = f"{DATA_DIR}/gold/analytics"

# Configure Plotly template and Mapbox token
MAPBOX_TOKEN = os.getenv('MAPBOX_TOKEN', '')
px.set_mapbox_access_token(MAPBOX_TOKEN)

# Enhance data loading with better error handling and caching
@st.cache_data(ttl=3600, show_spinner=True)
def load_data(table_name):
    """Load data from Delta table with enhanced error handling and performance optimization"""
    try:
        start_time = datetime.now()
        
        # Log data load attempt
        log_event(logger, 'data_load', 
                 f"Starting data load for {table_name}",
                 component='data_loader')
        
        # Read Delta table using default configurations
        df = spark.read.format("delta").load(f"{GOLD_PATH}/{table_name}")
        pdf = df.toPandas()
        
        duration_ms = (datetime.now() - start_time).total_seconds() * 1000
        
        # Log successful data load
        log_event(logger, 'data_load',
                 f"Successfully loaded {table_name}",
                 component='data_loader',
                 duration_ms=duration_ms,
                 data_size=len(pdf),
                 cache_hit=st.session_state.get(f'cache_hit_{table_name}', False))
        
        return pdf
    except Exception as e:
        # Log error with details
        log_event(logger, 'error',
                 f"Error loading {table_name}",
                 component='data_loader',
                 error_type=type(e).__name__,
                 error_details=str(e))
        raise  # Re-raise to be handled by the caller

def create_revenue_visualizations(revenue_data):
    """Create stylish revenue analysis visualizations"""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Monthly Revenue', 'Revenue vs Charged Trips',
                       'Trip Duration vs Revenue', 'Cumulative Revenue'),
        specs=[[{"type": "bar"}, {"type": "scatter"}],
               [{"type": "scatter"}, {"type": "scatter"}]]
    )

    # Monthly Revenue
    fig.add_trace(
        go.Bar(x=[f"{row['year']}-{row['month']:02d}" for _, row in revenue_data.iterrows()],
               y=revenue_data['revenue_potential'],
               marker_color='rgb(55, 83, 109)',
               showlegend=False),
        row=1, col=1
    )

    # Revenue vs Charged Trips
    fig.add_trace(
        go.Scatter(x=revenue_data['charged_trips'],
                  y=revenue_data['revenue_potential'],
                  mode='markers',
                  marker=dict(
                      size=10,
                      color=revenue_data['total_trips'],
                      colorscale='Viridis',
                      showscale=True,
                      colorbar=dict(title="Total Trips")
                  )),
        row=1, col=2
    )

    # Trip Duration vs Revenue
    fig.add_trace(
        go.Scatter(x=revenue_data['avg_duration_min'],
                  y=revenue_data['revenue_potential'],
                  mode='markers',
                  marker=dict(
                      size=10,
                      color=revenue_data['charged_trips'],
                      colorscale='Viridis',
                      showscale=True,
                      colorbar=dict(title="Charged Trips")
                  )),
        row=2, col=1
    )

    # Cumulative Revenue
    sorted_revenue = revenue_data.sort_values('revenue_potential', ascending=True)
    fig.add_trace(
        go.Scatter(x=range(len(sorted_revenue)),
                  y=sorted_revenue['revenue_potential'].cumsum(),
                  fill='tozeroy',
                  line=dict(color='rgb(55, 83, 109)')),
        row=2, col=2
    )

    fig.update_layout(
        height=800,
        showlegend=False,
        template='plotly_dark',
        title_text="Revenue Analysis Dashboard",
        xaxis_title="Month",
        xaxis2_title="Charged Trips",
        xaxis3_title="Average Duration (min)",
        xaxis4_title="Cumulative Count",
        yaxis_title="Revenue ($)",
        yaxis2_title="Revenue ($)",
        yaxis3_title="Revenue ($)",
        yaxis4_title="Cumulative Revenue ($)"
    )
    return fig

def create_station_map(station_data):
    """Create an interactive 3D station map"""
    station_data['size'] = np.log1p(station_data['total_starts']) * 50
    
    view_state = pdk.ViewState(
        latitude=station_data['start_lat'].mean(),
        longitude=station_data['start_lng'].mean(),
        zoom=11,
        pitch=45,
        bearing=0
    )

    column_layer = pdk.Layer(
        "ColumnLayer",
        data=station_data,
        get_position=['start_lng', 'start_lat'],
        get_elevation='size',
        elevation_scale=100,
        radius=50,
        get_fill_color=['avg_duration_min * 2', 'total_starts / 100', 'unique_destinations * 5', 140],
        pickable=True,
        auto_highlight=True
    )

    arc_layer = pdk.Layer(
        "ArcLayer",
        data=station_data.head(50),
        get_source=['start_lng', 'start_lat'],
        get_target=['start_lng', 'start_lat'],
        get_source_color=[200, 30, 0, 160],
        get_target_color=[0, 200, 30, 160],
        get_width='size / 10'
    )

    return pdk.Deck(
        layers=[column_layer, arc_layer],
        initial_view_state=view_state,
        map_style="mapbox://styles/mapbox/dark-v10",
        tooltip={
            'html': '<b>{start_station_name}</b><br/>'
                   'Total Starts: {total_starts}<br/>'
                   'Avg Duration: {avg_duration_min:.1f} min<br/>'
                   'Unique Destinations: {unique_destinations}',
            'style': {
                'backgroundColor': 'steelblue',
                'color': 'white'
            }
        }
    )

def create_temporal_analysis(temporal_data):
    """Create advanced temporal analysis visualizations"""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Hourly Usage Pattern', 'Weekly Pattern',
                       'Duration by Time of Day', 'Usage Heatmap'),
        specs=[[{"type": "scatter"}, {"type": "bar"}],
               [{"type": "bar"}, {"type": "heatmap"}]]
    )

    fig.add_trace(
        go.Scatter(x=temporal_data['part_of_day'],
                  y=temporal_data['total_rides'],
                  fill='tozeroy',
                  line=dict(color='rgb(55, 83, 109)')),
        row=1, col=1
    )

    weekly_data = temporal_data.groupby('is_weekend').agg({
        'total_rides': 'sum',
        'avg_duration_min': 'mean'
    }).reset_index()
    
    fig.add_trace(
        go.Bar(x=['Weekday' if not w else 'Weekend' for w in weekly_data['is_weekend']],
               y=weekly_data['total_rides'],
               marker_color='rgb(55, 83, 109)'),
        row=1, col=2
    )

    fig.add_trace(
        go.Bar(x=temporal_data['part_of_day'],
               y=temporal_data['avg_duration_min'],
               marker_color=temporal_data['total_rides'],
               marker=dict(colorscale='Viridis')),
        row=2, col=1
    )

    pivot_data = temporal_data.pivot_table(
        values='total_rides',
        index='part_of_day',
        columns='is_weekend',
        aggfunc='sum'
    )
    
    fig.add_trace(
        go.Heatmap(z=pivot_data.values,
                   x=['Weekday', 'Weekend'],
                   y=pivot_data.index,
                   colorscale='Viridis'),
        row=2, col=2
    )

    fig.update_layout(height=800,
                     template='plotly_dark',
                     title_text="Temporal Analysis Dashboard")
    return fig

def create_route_analysis(route_data):
    """Create interactive route analysis visualizations"""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Popular Routes', 'Distance vs Duration',
                       'Speed Distribution', 'Route Usage Patterns'),
        specs=[[{"type": "bar"}, {"type": "scatter"}],
               [{"type": "histogram"}, {"type": "scatter3d"}]]
    )

    top_routes = route_data.nlargest(10, 'route_count')
    fig.add_trace(
        go.Bar(x=top_routes['route_count'],
               y=top_routes['start_station_name'],
               orientation='h',
               marker_color='rgb(55, 83, 109)'),
        row=1, col=1
    )

    fig.add_trace(
        go.Scatter(x=route_data['avg_distance_km'],
                  y=route_data['avg_duration_min'],
                  mode='markers',
                  marker=dict(
                      size=8,
                      color=route_data['route_count'],
                      colorscale='Viridis',
                      showscale=True
                  )),
        row=1, col=2
    )

    fig.add_trace(
        go.Histogram(x=route_data['avg_speed_kmh'],
                    nbinsx=30,
                    marker_color='rgb(55, 83, 109)'),
        row=2, col=1
    )

    fig.add_trace(
        go.Scatter3d(x=route_data['avg_distance_km'],
                     y=route_data['avg_duration_min'],
                     z=route_data['route_count'],
                     mode='markers',
                     marker=dict(
                         size=6,
                         color=route_data['avg_speed_kmh'],
                         colorscale='Viridis',
                         opacity=0.8
                     )),
        row=2, col=2
    )

    fig.update_layout(height=800,
                     template='plotly_dark',
                     title_text="Route Analysis Dashboard")
    return fig

def main():
    try:
        # Initialize session state
        if 'session_id' not in st.session_state:
            st.session_state['session_id'] = datetime.now().strftime('%Y%m%d-%H%M%S')
            log_event(logger, 'session',
                     "New session started",
                     component='session_manager')
        
        # Page configuration
        st.set_page_config(
            page_title="NYC Bike Share Analytics",
            page_icon="🚲",
            layout="wide",
            initial_sidebar_state="expanded"
        )
        
        # Track page navigation
        page = st.sidebar.selectbox(
            "Choose Analysis",
            ["💰 Revenue Analysis", "🚉 Station Analysis", "⏰ Temporal Analysis", "🛣️ Route Analysis"]
        )
        
        if 'current_page' not in st.session_state or st.session_state['current_page'] != page:
            st.session_state['current_page'] = page
            log_event(logger, 'navigation',
                     f"Page navigation to {page}",
                     component='navigation')
        
        # Add error recovery state
        if 'error_count' not in st.session_state:
            st.session_state['error_count'] = 0
        
        try:
            if page == "💰 Revenue Analysis":
                start_time = datetime.now()
                st.header("💰 Revenue Analysis")
                
                # Show loading message
                with st.spinner('Loading revenue data...'):
                    revenue_data = load_data("revenue_metrics")
                
                if revenue_data is not None:
                    try:
                        # Sort data by year and month
                        revenue_data = revenue_data.sort_values(['year', 'month'])
                        
                        # Calculate metrics first to catch any computation errors
                        total_revenue = revenue_data['revenue_potential'].sum()
                        total_trips = revenue_data['total_trips'].sum()
                        avg_duration = revenue_data['avg_duration_min'].mean()
                        revenue_per_trip = total_revenue / total_trips
                        
                        # Display metrics
                        col1, col2, col3, col4 = st.columns(4)
                        with col1:
                            st.metric("Total Revenue", f"${total_revenue:.2f}")
                        with col2:
                            st.metric("Total Trips", f"{total_trips:,.0f}")
                        with col3:
                            st.metric("Avg Trip Duration", f"{avg_duration:.1f} min")
                        with col4:
                            st.metric("Revenue per Trip", f"${revenue_per_trip:.2f}")
                        
                        # Create visualization with error handling
                        try:
                            fig = create_revenue_visualizations(revenue_data)
                            st.plotly_chart(fig, use_container_width=True)
                        except Exception as viz_error:
                            log_event(logger, 'error',
                                    "Failed to create visualization",
                                    component='revenue_analysis',
                                    error_type=type(viz_error).__name__,
                                    error_details=str(viz_error))
                            st.error("Failed to create visualization. Please try refreshing the page.")
                        
                        # Reset error count on success
                        st.session_state['error_count'] = 0
                        
                    except Exception as calc_error:
                        log_event(logger, 'error',
                                "Failed to calculate metrics",
                                component='revenue_analysis',
                                error_type=type(calc_error).__name__,
                                error_details=str(calc_error))
                        st.error("Failed to calculate metrics. Please try refreshing the page.")
                
                duration_ms = (datetime.now() - start_time).total_seconds() * 1000
                log_event(logger, 'visualization',
                         "Revenue analysis rendered",
                         component='revenue_analysis',
                         duration_ms=duration_ms)
            
            # Similar structure for other pages...
            
        except Exception as page_error:
            st.session_state['error_count'] += 1
            log_event(logger, 'error',
                     "Page rendering error",
                     component='main',
                     error_type=type(page_error).__name__,
                     error_details=str(page_error),
                     error_count=st.session_state['error_count'])
            
            # If too many errors, suggest session reset
            if st.session_state['error_count'] >= 3:
                st.error("Multiple errors occurred. Please try clearing your browser cache and refreshing the page.")
            else:
                st.error("An error occurred while loading the page. Please try again.")
            
            # Try to recover Spark session if needed
            if isinstance(page_error, Exception) and "Spark" in str(page_error):
                try:
                    spark = create_spark_session()
                    st.info("Reconnected to Spark. Please try your action again.")
                except Exception:
                    st.error("Could not reconnect to Spark. Please refresh the page.")
    
    except Exception as e:
        logger.error("Dashboard crashed", exc_info=True)
        st.error("An unexpected error occurred. Please refresh the page and try again.")

# Add session cleanup
def cleanup_spark_session():
    """Cleanup Spark session on app shutdown"""
    if 'spark' in globals():
        try:
            spark.stop()
            log_event(logger, 'cleanup',
                     "Spark session stopped",
                     component='spark_session')
        except Exception as e:
            log_event(logger, 'error',
                     "Failed to stop Spark session",
                     component='spark_session',
                     error_type=type(e).__name__,
                     error_details=str(e))

# Register cleanup handler
import atexit
atexit.register(cleanup_spark_session)

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logger.error("Dashboard crashed", exc_info=True)
        st.error("An unexpected error occurred. Please try again later.")