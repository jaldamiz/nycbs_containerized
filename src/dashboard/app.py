import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pydeck as pdk
from datetime import datetime
import os
from pyspark.sql import SparkSession
from dotenv import load_dotenv
from delta import *

# Load environment variables
load_dotenv()

# Initialize Spark Session
def create_spark_session():
    """Create a Spark session using central configuration"""
    try:
        spark = (SparkSession.builder
                .appName("NYC Bike Share Dashboard")
                .getOrCreate())
        return spark
    except Exception as e:
        st.error(f"Failed to initialize Spark: {str(e)}")
        st.stop()

# Initialize Spark session
spark = create_spark_session()

# Data paths
DATA_DIR = os.getenv('DATA_DIR', '/home/aldamiz/data')
GOLD_PATH = f"{DATA_DIR}/gold/analytics"

# Configure Plotly template and Mapbox token
MAPBOX_TOKEN = os.getenv('MAPBOX_TOKEN', '')
px.set_mapbox_access_token(MAPBOX_TOKEN)

@st.cache_data(ttl=3600, show_spinner=True)
def load_data(table_name):
    """Load data from Delta table"""
    try:
        df = spark.read.format("delta").load(f"{GOLD_PATH}/{table_name}")
        return df.toPandas()
    except Exception as e:
        st.error(f"Error loading {table_name}: {str(e)}")
        return None

def create_revenue_visualizations(revenue_data):
    """Create revenue analysis visualizations"""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Monthly Revenue', 'Revenue vs Charged Trips',
                       'Trip Duration vs Revenue', 'Cumulative Revenue'),
        specs=[[{"type": "bar"}, {"type": "scatter"}],
               [{"type": "scatter"}, {"type": "scatter"}]],
        vertical_spacing=0.12,
        horizontal_spacing=0.1
    )

    # Monthly Revenue - with fixed month formatting
    x_labels = [f"{int(row['year'])}-{int(row['month']):02d}" for _, row in revenue_data.iterrows()]
    fig.add_trace(
        go.Bar(x=x_labels,
               y=revenue_data['revenue_potential'],
               marker_color='rgb(55, 83, 109)',
               width=0.7,  # Adjust bar width
               showlegend=False),
        row=1, col=1
    )

    # Revenue vs Charged Trips
    fig.add_trace(
        go.Scatter(x=revenue_data['charged_trips'].values,
                  y=revenue_data['revenue_potential'].values,
                  mode='markers',
                  marker=dict(
                      size=15,  # Increased marker size
                      color=revenue_data['total_trips'].values,
                      colorscale='Viridis',
                      showscale=True,
                      colorbar=dict(
                          title="Total Trips",
                          thickness=15,
                          len=0.7
                      )
                  )),
        row=1, col=2
    )

    # Trip Duration vs Revenue
    fig.add_trace(
        go.Scatter(x=revenue_data['avg_duration_min'].values,
                  y=revenue_data['revenue_potential'].values,
                  mode='markers',
                  marker=dict(
                      size=15,  # Increased marker size
                      color=revenue_data['charged_trips'].values,
                      colorscale='Viridis',
                      showscale=True,
                      colorbar=dict(
                          title="Charged Trips",
                          thickness=15,
                          len=0.7
                      )
                  )),
        row=2, col=1
    )

    # Cumulative Revenue
    sorted_revenue = revenue_data.sort_values('revenue_potential', ascending=True)
    cumulative_revenue = sorted_revenue['revenue_potential'].cumsum().values
    
    fig.add_trace(
        go.Scatter(x=list(range(1, len(sorted_revenue) + 1)),  # Start from 1 for better readability
                  y=cumulative_revenue,
                  fill='tozeroy',
                  line=dict(color='rgb(55, 83, 109)', width=2),
                  showlegend=False),
        row=2, col=2
    )

    # Update layout with better formatting
    fig.update_layout(
        height=800,
        showlegend=False,
        template='plotly_dark',
        title_text="Revenue Analysis Dashboard",
        title_x=0.5,  # Center the title
        title_y=0.95,  # Move title up slightly
        font=dict(size=12),
        plot_bgcolor='rgba(0,0,0,0)',
        paper_bgcolor='rgba(0,0,0,0)'
    )

    # Update axes labels and formatting
    fig.update_xaxes(title_text="Month", row=1, col=1, tickangle=45)
    fig.update_xaxes(title_text="Charged Trips", row=1, col=2)
    fig.update_xaxes(title_text="Average Duration (min)", row=2, col=1)
    fig.update_xaxes(title_text="Data Points", row=2, col=2)
    
    fig.update_yaxes(title_text="Revenue ($)", row=1, col=1)
    fig.update_yaxes(title_text="Revenue ($)", row=1, col=2)
    fig.update_yaxes(title_text="Revenue ($)", row=2, col=1)
    fig.update_yaxes(title_text="Cumulative Revenue ($)", row=2, col=2)

    return fig

def create_station_map(station_data):
    """Create an interactive 3D station map"""
    # Calculate normalized metrics for better visualization
    station_data['elevation'] = np.log1p(station_data['total_starts']) * 20  # Reduced multiplier
    station_data['radius'] = np.log1p(station_data['unique_destinations']) * 10
    
    # Create color based on average duration
    station_data['color_value'] = station_data['avg_duration_min']
    
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
        get_elevation='elevation',
        elevation_scale=5,  # Reduced scale
        radius='radius',
        get_fill_color=['color_value', 'color_value * 2', 'color_value * 3', 180],
        pickable=True,
        auto_highlight=True,
        extruded=True
    )

    return pdk.Deck(
        layers=[column_layer],
        initial_view_state=view_state,
        map_style="mapbox://styles/mapbox/dark-v10",
        tooltip={
            'html': '<b>{start_station_name}</b><br/>'
                   'Total Starts: {total_starts:,}<br/>'
                   'Avg Duration: {avg_duration_min:.1f} min<br/>'
                   'Unique Destinations: {unique_destinations}<br/>'
                   'Avg Distance: {avg_distance_km:.1f} km',
            'style': {
                'backgroundColor': 'rgba(0, 0, 0, 0.8)',
                'color': 'white',
                'fontSize': '12px',
                'padding': '8px'
            }
        }
    )

def create_station_analytics(station_data):
    """Create additional station analytics visualizations"""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=(
            'Top 10 Busiest Stations',
            'Station Connectivity Distribution',
            'Duration vs Distance',
            'Starts vs Destinations'
        ),
        specs=[
            [{"type": "bar"}, {"type": "histogram"}],
            [{"type": "scatter"}, {"type": "scatter"}]
        ],
        vertical_spacing=0.15,
        horizontal_spacing=0.1
    )

    # Top 10 Busiest Stations
    top_stations = station_data.groupby('start_station_name')['total_starts'].sum().nlargest(10)
    fig.add_trace(
        go.Bar(
            x=top_stations.values,
            y=top_stations.index,
            orientation='h',
            marker_color='rgb(55, 83, 109)',
            name='Total Starts'
        ),
        row=1, col=1
    )

    # Station Connectivity Distribution
    fig.add_trace(
        go.Histogram(
            x=station_data['unique_destinations'],
            nbinsx=30,
            marker_color='rgb(55, 83, 109)',
            name='Stations'
        ),
        row=1, col=2
    )

    # Duration vs Distance Scatter
    fig.add_trace(
        go.Scatter(
            x=station_data['avg_distance_km'],
            y=station_data['avg_duration_min'],
            mode='markers',
            marker=dict(
                size=8,
                color=station_data['total_starts'],
                colorscale='Viridis',
                showscale=True,
                colorbar=dict(
                    title="Total Starts",
                    thickness=15,
                    len=0.7,
                    y=0.23,
                    yanchor='bottom'
                )
            ),
            name='Stations'
        ),
        row=2, col=1
    )

    # Starts vs Destinations Scatter
    fig.add_trace(
        go.Scatter(
            x=station_data['unique_destinations'],
            y=station_data['total_starts'],
            mode='markers',
            marker=dict(
                size=8,
                color=station_data['avg_duration_min'],
                colorscale='Viridis',
                showscale=True,
                colorbar=dict(
                    title="Avg Duration (min)",
                    thickness=15,
                    len=0.7,
                    y=0.23,
                    yanchor='bottom'
                )
            ),
            name='Stations'
        ),
        row=2, col=2
    )

    # Update layout
    fig.update_layout(
        height=800,
        showlegend=False,
        template='plotly_dark',
        title_text="Station Analytics Dashboard",
        title_x=0.5,
        title_y=0.95,
        font=dict(size=12),
        plot_bgcolor='rgba(0,0,0,0)',
        paper_bgcolor='rgba(0,0,0,0)'
    )

    # Update axes labels
    fig.update_xaxes(title_text="Total Starts", row=1, col=1)
    fig.update_xaxes(title_text="Unique Destinations", row=1, col=2)
    fig.update_xaxes(title_text="Average Distance (km)", row=2, col=1)
    fig.update_xaxes(title_text="Unique Destinations", row=2, col=2)
    
    fig.update_yaxes(title_text="Station", row=1, col=1)
    fig.update_yaxes(title_text="Number of Stations", row=1, col=2)
    fig.update_yaxes(title_text="Average Duration (min)", row=2, col=1)
    fig.update_yaxes(title_text="Total Starts", row=2, col=2)

    return fig

def create_temporal_analysis(temporal_data):
    """Create temporal analysis visualizations"""
    # Define correct time period order
    time_order = ['morning', 'afternoon', 'evening', 'night']
    temporal_data['part_of_day'] = pd.Categorical(temporal_data['part_of_day'], categories=time_order, ordered=True)
    temporal_data = temporal_data.sort_values('part_of_day')

    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Hourly Usage Pattern', 'Weekly Pattern',
                       'Duration by Time of Day', 'Usage Heatmap'),
        specs=[[{"type": "bar"}, {"type": "bar"}],
               [{"type": "bar"}, {"type": "heatmap"}]],
        vertical_spacing=0.15,
        horizontal_spacing=0.1
    )

    # Hourly Usage Pattern - Changed to bar chart for clarity
    hourly_data = temporal_data.groupby('part_of_day')['total_rides'].mean().reindex(time_order)
    fig.add_trace(
        go.Bar(x=time_order,
               y=hourly_data.values,
               marker_color='rgb(55, 83, 109)',
               width=0.7,
               name='Average Rides'),
        row=1, col=1
    )

    # Weekly Pattern
    weekly_data = temporal_data.groupby('is_weekend').agg({
        'total_rides': 'sum',
        'avg_duration_min': 'mean'
    }).reset_index()
    
    fig.add_trace(
        go.Bar(x=['Weekday' if not w else 'Weekend' for w in weekly_data['is_weekend']],
               y=weekly_data['total_rides'],
               marker_color='rgb(55, 83, 109)',
               width=0.6,
               name='Total Rides'),
        row=1, col=2
    )

    # Duration by Time of Day
    duration_data = temporal_data.groupby('part_of_day')['avg_duration_min'].mean().reindex(time_order)
    fig.add_trace(
        go.Bar(x=time_order,
               y=duration_data.values,
               marker_color=temporal_data.groupby('part_of_day')['total_rides'].mean().values,
               marker=dict(
                   colorscale='Viridis',
                   showscale=True,
                   colorbar=dict(
                       title="Average Rides",
                       thickness=15,
                       len=0.7,
                       y=0.23,  # Adjust position to bottom half
                       yanchor='bottom'
                   )
               ),
               name='Average Duration'),
        row=2, col=1
    )

    # Usage Heatmap
    pivot_data = temporal_data.pivot_table(
        values='total_rides',
        index='part_of_day',
        columns='is_weekend',
        aggfunc='mean'
    ).reindex(time_order)
    
    fig.add_trace(
        go.Heatmap(z=pivot_data.values,
                   x=['Weekday', 'Weekend'],
                   y=time_order,
                   colorscale='Viridis',
                   colorbar=dict(
                       title="Average Rides",
                       thickness=15,
                       len=0.7,
                       y=0.23,  # Adjust position to bottom half
                       yanchor='bottom'
                   )),
        row=2, col=2
    )

    # Update layout with better formatting
    fig.update_layout(
        height=800,
        showlegend=False,
        template='plotly_dark',
        title_text="Temporal Analysis Dashboard",
        title_x=0.5,
        title_y=0.95,
        font=dict(size=12),
        plot_bgcolor='rgba(0,0,0,0)',
        paper_bgcolor='rgba(0,0,0,0)'
    )

    # Update axes labels and formatting
    fig.update_xaxes(title_text="Time of Day", row=1, col=1)
    fig.update_xaxes(title_text="Day Type", row=1, col=2)
    fig.update_xaxes(title_text="Time of Day", row=2, col=1)
    fig.update_xaxes(title_text="Day Type", row=2, col=2)
    
    fig.update_yaxes(title_text="Average Number of Rides", row=1, col=1)
    fig.update_yaxes(title_text="Total Number of Rides", row=1, col=2)
    fig.update_yaxes(title_text="Average Duration (min)", row=2, col=1)
    fig.update_yaxes(title_text="Time of Day", row=2, col=2)

    # Format axis numbers
    fig.update_layout(
        yaxis=dict(tickformat=",d"),  # Add thousands separator
        yaxis2=dict(tickformat=",d"),
        yaxis3=dict(tickformat=".1f")
    )

    return fig

def create_route_analysis(route_data):
    """Create route analysis visualizations"""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Top 10 Routes', 'Distance vs Duration',
                       'Speed Distribution', 'Route Usage Patterns'),
        specs=[[{"type": "bar"}, {"type": "scatter"}],
               [{"type": "histogram"}, {"type": "scatter3d"}]],
        vertical_spacing=0.12,
        horizontal_spacing=0.1
    )

    # Top 10 Routes
    top_routes = route_data.nlargest(10, 'route_count')
    fig.add_trace(
        go.Bar(x=top_routes['route_count'],
               y=top_routes['start_station_name'],
               orientation='h',
               marker_color='rgb(55, 83, 109)',
               width=0.7),
        row=1, col=1
    )

    # Distance vs Duration
    fig.add_trace(
        go.Scatter(x=route_data['avg_distance_km'],
                  y=route_data['avg_duration_min'],
                  mode='markers',
                  marker=dict(
                      size=12,
                      color=route_data['route_count'],
                      colorscale='Viridis',
                      showscale=True,
                      colorbar=dict(title="Route Count")
                  )),
        row=1, col=2
    )

    # Speed Distribution
    fig.add_trace(
        go.Histogram(x=route_data['avg_speed_kmh'],
                    nbinsx=30,
                    marker_color='rgb(55, 83, 109)'),
        row=2, col=1
    )

    # 3D Route Usage
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

    fig.update_layout(
        height=800,
        showlegend=False,
        template='plotly_dark',
        title_text="Route Analysis Dashboard",
        title_x=0.5,
        font=dict(size=12)
    )

    return fig

def main():
    # Page configuration
    st.set_page_config(
        page_title="NYC Bike Share Analytics",
        page_icon="🚲",
        layout="wide",
        initial_sidebar_state="expanded"
    )
    
    # Navigation
    page = st.sidebar.selectbox(
        "Choose Analysis",
        ["💰 Revenue Analysis", "🚉 Station Analysis", "⏰ Temporal Analysis", "🛣️ Route Analysis"]
    )
    
    try:
        if page == "💰 Revenue Analysis":
            st.header("💰 Revenue Analysis")
            revenue_data = load_data("revenue_metrics")
            
            if revenue_data is not None:
                # Process revenue data and create visualizations
                revenue_data = revenue_data.sort_values(['year', 'month'])
                revenue_data = revenue_data.astype({
                    'year': int,
                    'month': int,
                    'revenue_potential': np.float64,
                    'total_trips': np.int64,
                    'charged_trips': np.int64,
                    'avg_duration_min': np.float64
                })
                
                # Calculate and display metrics
                total_revenue = revenue_data['revenue_potential'].sum()
                total_trips = revenue_data['total_trips'].sum()
                avg_duration = revenue_data['avg_duration_min'].mean()
                revenue_per_trip = total_revenue / total_trips if total_trips > 0 else 0.0
                
                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    st.metric("Total Revenue", f"${total_revenue:,.2f}")
                with col2:
                    st.metric("Total Trips", f"{total_trips:,}")
                with col3:
                    st.metric("Avg Trip Duration", f"{avg_duration:.1f} min")
                with col4:
                    st.metric("Revenue per Trip", f"${revenue_per_trip:.3f}")
                
                # Create and display visualizations
                fig = create_revenue_visualizations(revenue_data)
                st.plotly_chart(fig, use_container_width=True)
        
        elif page == "🚉 Station Analysis":
            st.header("🚉 Station Analysis")
            station_data = load_data("station_metrics")
            
            if station_data is not None:
                # Process station data
                station_data = station_data.astype({
                    'year': int,
                    'month': int,
                    'total_starts': np.int64,
                    'avg_duration_min': np.float64,
                    'avg_distance_km': np.float64,
                    'unique_destinations': np.int64
                })
                
                # Display metrics
                total_stations = len(station_data['start_station_name'].unique())
                total_starts = station_data['total_starts'].sum()
                avg_destinations = station_data['unique_destinations'].mean()
                avg_distance = station_data['avg_distance_km'].mean()
                
                # Metrics in two rows for better layout
                col1, col2 = st.columns(2)
                with col1:
                    metric_col1, metric_col2 = st.columns(2)
                    with metric_col1:
                        st.metric("Total Stations", f"{total_stations:,}")
                    with metric_col2:
                        st.metric("Total Starts", f"{total_starts:,}")
                with col2:
                    metric_col3, metric_col4 = st.columns(2)
                    with metric_col3:
                        st.metric("Avg Destinations/Station", f"{avg_destinations:.1f}")
                    with metric_col4:
                        st.metric("Avg Distance/Trip", f"{avg_distance:.1f} km")
                
                # Create tabs for map and analytics
                tab1, tab2 = st.tabs(["📍 Station Map", "📊 Station Analytics"])
                
                with tab1:
                    st.pydeck_chart(create_station_map(station_data))
                    st.caption("Height: Total Starts | Radius: Unique Destinations | Color: Average Duration")
                
                with tab2:
                    fig = create_station_analytics(station_data)
                    st.plotly_chart(fig, use_container_width=True)
        
        elif page == "⏰ Temporal Analysis":
            st.header("⏰ Temporal Analysis")
            temporal_data = load_data("temporal_metrics")
            
            if temporal_data is not None:
                # Process temporal data
                temporal_data = temporal_data.astype({
                    'year': int,
                    'month': int,
                    'total_rides': np.int64,
                    'avg_duration_min': np.float64,
                    'avg_distance_km': np.float64,
                    'avg_speed_kmh': np.float64
                })
                
                # Display metrics
                weekday_rides = temporal_data[~temporal_data['is_weekend']]['total_rides'].sum()
                weekend_rides = temporal_data[temporal_data['is_weekend']]['total_rides'].sum()
                weekday_pct = weekday_rides / (weekday_rides + weekend_rides) * 100
                
                col1, col2, col3 = st.columns(3)
                with col1:
                    st.metric("Weekday Rides", f"{weekday_rides:,}")
                with col2:
                    st.metric("Weekend Rides", f"{weekend_rides:,}")
                with col3:
                    st.metric("Weekday %", f"{weekday_pct:.1f}%")
                
                # Create and display visualizations
                fig = create_temporal_analysis(temporal_data)
                st.plotly_chart(fig, use_container_width=True)
        
        elif page == "🛣️ Route Analysis":
            st.header("🛣️ Route Analysis")
            route_data = load_data("route_metrics")
            
            if route_data is not None:
                # Process route data
                route_data = route_data.astype({
                    'year': int,
                    'month': int,
                    'route_count': np.int64,
                    'avg_distance_km': np.float64,
                    'avg_duration_min': np.float64,
                    'avg_speed_kmh': np.float64
                })
                
                # Display metrics
                total_routes = len(route_data)
                avg_distance = route_data['avg_distance_km'].mean()
                avg_speed = route_data['avg_speed_kmh'].mean()
                
                col1, col2, col3 = st.columns(3)
                with col1:
                    st.metric("Total Routes", f"{total_routes:,}")
                with col2:
                    st.metric("Avg Distance", f"{avg_distance:.1f} km")
                with col3:
                    st.metric("Avg Speed", f"{avg_speed:.1f} km/h")
                
                # Create and display visualizations
                fig = create_route_analysis(route_data)
                st.plotly_chart(fig, use_container_width=True)
    
    except Exception as e:
        st.error(f"An error occurred: {str(e)}")
        st.write("Error details:", str(e.__class__), str(e.__dict__))
        import traceback
        st.write("Traceback:", traceback.format_exc())

if __name__ == "__main__":
    main()