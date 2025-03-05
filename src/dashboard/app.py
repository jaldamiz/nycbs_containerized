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

# Load environment variables
load_dotenv()

# Configure logging
LOG_DIR = os.getenv('LOG_DIR', '/home/aldamiz/logs/streamlit')
LOG_FILE = os.path.join(LOG_DIR, 'streamlit.log')

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

def setup_logging():
    """Configure logging to file and logstash"""
    logger = logging.getLogger('streamlit_logger')
    logger.setLevel(logging.INFO)
    
    # Ensure log directory exists
    os.makedirs(LOG_DIR, exist_ok=True)
    
    # File handler with rotation
    file_handler = logging.handlers.RotatingFileHandler(
        LOG_FILE,
        maxBytes=10485760,  # 10MB
        backupCount=5
    )
    file_handler.setFormatter(JsonFormatter())
    
    # Logstash handler
    logstash_handler = logging.handlers.SocketHandler(
        'localhost',
        5000
    )
    logstash_handler.setFormatter(JsonFormatter())
    
    # Add handlers
    logger.addHandler(file_handler)
    logger.addHandler(logstash_handler)
    
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

# Initialize Spark Session
spark = (SparkSession.builder
         .appName("NYC Bike Share Dashboard")
         .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
         .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
         .config("spark.sql.warehouse.dir", "/home/aldamiz/warehouse")
         .config("spark.driver.memory", "4g")
         .getOrCreate())

# Data paths
DATA_DIR = os.getenv('DATA_DIR', '/home/aldamiz/data')
GOLD_PATH = f"{DATA_DIR}/gold/analytics"

# Configure Plotly template and Mapbox token
MAPBOX_TOKEN = os.getenv('MAPBOX_TOKEN', '')
px.set_mapbox_access_token(MAPBOX_TOKEN)

@st.cache_data(ttl=3600)
def load_data(table_name):
    """Load data from Delta table with enhanced error handling and logging"""
    try:
        start_time = datetime.now()
        
        # Log data load attempt
        log_event(logger, 'data_load', 
                 f"Starting data load for {table_name}",
                 component='data_loader')
        
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
        st.error(f"Error loading {table_name}: {str(e)}")
        return None

def create_revenue_visualizations(revenue_data):
    """Create stylish revenue analysis visualizations"""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Revenue by Time of Day', 'Revenue Distribution by Distance',
                       'Trip Duration vs Revenue', 'Cumulative Revenue'),
        specs=[[{"type": "bar"}, {"type": "pie"}],
               [{"type": "scatter"}, {"type": "scatter"}]]
    )

    fig.add_trace(
        go.Bar(x=revenue_data['part_of_day'],
               y=revenue_data['revenue_usd'],
               marker_color='rgb(55, 83, 109)',
               showlegend=False),
        row=1, col=1
    )

    fig.add_trace(
        go.Pie(labels=revenue_data['distance_bucket'],
               values=revenue_data['revenue_usd'],
               hole=0.4,
               marker=dict(colors=px.colors.sequential.Viridis)),
        row=1, col=2
    )

    fig.add_trace(
        go.Scatter(x=revenue_data['avg_duration_min'],
                  y=revenue_data['revenue_usd'],
                  mode='markers',
                  marker=dict(
                      size=8,
                      color=revenue_data['trip_count'],
                      colorscale='Viridis',
                      showscale=True
                  )),
        row=2, col=1
    )

    sorted_revenue = revenue_data.sort_values('revenue_usd', ascending=True)
    fig.add_trace(
        go.Scatter(x=range(len(sorted_revenue)),
                  y=sorted_revenue['revenue_usd'].cumsum(),
                  fill='tozeroy',
                  line=dict(color='rgb(55, 83, 109)')),
        row=2, col=2
    )

    fig.update_layout(height=800, showlegend=False,
                     template='plotly_dark',
                     title_text="Revenue Analysis Dashboard")
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
        get_fill_color=['avg_ride_duration * 2', 'total_starts / 100', 'unique_destinations * 5', 140],
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
                   'Avg Duration: {avg_ride_duration:.1f} min<br/>'
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
        'avg_duration': 'mean'
    }).reset_index()
    
    fig.add_trace(
        go.Bar(x=['Weekday' if not w else 'Weekend' for w in weekly_data['is_weekend']],
               y=weekly_data['total_rides'],
               marker_color='rgb(55, 83, 109)'),
        row=1, col=2
    )

    fig.add_trace(
        go.Bar(x=temporal_data['part_of_day'],
               y=temporal_data['avg_duration'],
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
    
    # Rest of your main function code...
    try:
        if page == "💰 Revenue Analysis":
            start_time = datetime.now()
            st.header("💰 Revenue Analysis")
            revenue_data = load_data("revenue_metrics")
            
            if revenue_data is not None:
                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    st.metric("Total Revenue", f"${revenue_data['revenue_usd'].sum():,.2f}")
                with col2:
                    st.metric("Total Trips", f"{revenue_data['total_trips'].sum():,}")
                with col3:
                    st.metric("Avg Trip Duration", f"{revenue_data['avg_duration_min'].mean():.1f} min")
                with col4:
                    st.metric("Revenue per Trip", 
                             f"${revenue_data['revenue_usd'].sum() / revenue_data['total_trips'].sum():.2f}")
                
                st.plotly_chart(create_revenue_visualizations(revenue_data),
                               use_container_width=True)
            duration_ms = (datetime.now() - start_time).total_seconds() * 1000
            log_event(logger, 'visualization',
                     "Revenue analysis rendered",
                     component='revenue_analysis',
                     duration_ms=duration_ms)
        
        # Similar logging for other pages...
        
    except Exception as e:
        log_event(logger, 'error',
                 "Dashboard error",
                 component='main',
                 error_type=type(e).__name__,
                 error_details=str(e))
        st.error("An unexpected error occurred. Please try again later.")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logger.error("Dashboard crashed", exc_info=True)
        st.error("An unexpected error occurred. Please try again later.")