# Streamlit Dashboard Documentation

## Overview

The NYC Bike Share Analytics dashboard provides interactive visualizations and insights through a Streamlit web application. The dashboard presents various analytics views derived from the gold layer tables.

## Features

### 1. Revenue Analysis
```python
# Revenue metrics visualization
revenue_data = load_data("revenue_metrics")
create_revenue_visualizations(revenue_data)
```

#### Available Views
- Monthly revenue trends
- Revenue vs charged trips
- Trip duration analysis
- Cumulative revenue

#### Key Metrics
- Total revenue
- Number of trips
- Average duration
- Revenue per trip

### 2. Station Analytics
```python
# Station map and metrics
station_data = load_data("station_metrics")
create_station_map(station_data)
create_station_analytics(station_data)
```

#### Map View
- 3D station visualization
- Color-coded by usage
- Interactive tooltips
- Zoom and pan controls

#### Analytics Views
- Top 10 busiest stations
- Station connectivity
- Duration vs distance
- Usage patterns

### 3. Temporal Analysis
```python
# Time-based analysis
temporal_data = load_data("temporal_metrics")
create_temporal_analysis(temporal_data)
```

#### Time Patterns
- Hourly usage patterns
- Weekly trends
- Weekend vs weekday
- Seasonal variations

#### Metrics
- Usage by time of day
- Peak hours analysis
- Duration patterns
- Speed variations

### 4. Route Analysis
```python
# Popular routes visualization
route_data = load_data("route_metrics")
create_route_analysis(route_data)
```

#### Route Views
- Popular route maps
- Distance distribution
- Speed patterns
- Usage frequency

## Implementation

### 1. Data Loading
```python
@st.cache_data(ttl=3600)
def load_data(table_name):
    """Load data from Delta table with caching"""
    try:
        df = spark.read.format("delta").load(f"{GOLD_PATH}/{table_name}")
        return df.toPandas()
    except Exception as e:
        st.error(f"Error loading {table_name}: {str(e)}")
        return None
```

### 2. Visualization Components
```python
def create_revenue_visualizations(revenue_data):
    """Create revenue analysis visualizations"""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=(
            'Monthly Revenue',
            'Revenue vs Charged Trips',
            'Trip Duration vs Revenue',
            'Cumulative Revenue'
        )
    )
    # ... visualization code ...
```

### 3. Interactive Features
```python
# Date range selector
start_date = st.date_input("Start Date")
end_date = st.date_input("End Date")

# Metric selector
selected_metrics = st.multiselect(
    "Select Metrics",
    ["Revenue", "Trips", "Duration", "Speed"]
)
```

## Layout

### 1. Sidebar
- Date range selection
- Metric filters
- View options
- Export controls

### 2. Main Content
- Key metrics overview
- Primary visualizations
- Detailed analytics
- Data tables

### 3. Components
```python
# Page layout
st.set_page_config(
    page_title="NYC Bike Share Analytics",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Sidebar configuration
with st.sidebar:
    st.title("Analytics Controls")
    # ... controls ...

# Main content
col1, col2 = st.columns(2)
with col1:
    # ... content ...
```

## Performance

### 1. Data Caching
```python
# Cache configuration
st.cache_data(ttl=3600, show_spinner=True)
st.cache_resource(ttl=3600)
```

### 2. Optimization
- Data aggregation
- Lazy loading
- Resource caching
- Query optimization

### 3. Monitoring
```python
# Performance logging
start_time = time.time()
result = expensive_operation()
duration = time.time() - start_time
st.write(f"Operation took {duration:.2f} seconds")
```

## Customization

### 1. Theme Configuration
```python
# Custom theme
st.set_page_config(
    page_icon="🚲",
    initial_sidebar_state="expanded",
    layout="wide"
)
```

### 2. Style Settings
```python
# Custom CSS
st.markdown("""
<style>
.big-font {
    font-size:24px !important;
}
</style>
""", unsafe_allow_html=True)
```

### 3. Chart Settings
```python
# Plotly template
import plotly.io as pio
pio.templates.default = "plotly_dark"
```

## Error Handling

### 1. Data Loading
```python
try:
    data = load_data("revenue_metrics")
    if data is None:
        st.error("Failed to load data")
        st.stop()
except Exception as e:
    st.error(f"Error: {str(e)}")
```

### 2. User Input
```python
if start_date > end_date:
    st.warning("Start date must be before end date")
    st.stop()
```

### 3. Resource Management
```python
@st.cache_resource(ttl=3600)
def create_spark_session():
    try:
        return SparkSession.builder.getOrCreate()
    except Exception as e:
        st.error(f"Failed to create Spark session: {str(e)}")
        return None
```

## Usage Guide

### 1. Navigation
1. Select date range
2. Choose metrics
3. Explore visualizations
4. Export results

### 2. Interactivity
- Click and drag to zoom
- Hover for details
- Double-click to reset
- Use filters to refine

### 3. Export Options
- Download data as CSV
- Save charts as PNG
- Export to Excel
- Share links

## Related Documentation

- [Analytics Overview](../4_analytics/visualizations.md)
- [Data Dictionary](../3_data_pipeline/schemas.md)
- [Performance Monitoring](../5_operations/monitoring.md) 