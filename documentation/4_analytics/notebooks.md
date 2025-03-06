# Jupyter Notebooks Documentation

## Overview

The NYC Bike Share Analytics project uses Jupyter notebooks for data analysis, processing, and pipeline development. The main notebook `nycbs.ipynb` implements the complete data pipeline from ingestion to analytics.

## Main Notebook: nycbs.ipynb

### 1. Structure
```python
# Notebook sections
1. Setup and Imports
2. Control Table Setup
3. Data Ingestion
4. Bronze Layer Processing
5. Silver Layer Transformations
6. Gold Layer Analytics
```

### 2. Setup and Configuration
```python
# Import libraries
import os
import time
from datetime import datetime
import logging
import pandas as pd
import numpy as np
from pyspark.sql import SparkSession
from delta.tables import DeltaTable

# Initialize logger
from utils.notebook_logger import NotebookLogger
logger = NotebookLogger('nycbs')

# Initialize Spark
spark = SparkSession.builder.appName("NYCBS_Analysis").getOrCreate()
```

### 3. Data Pipeline Implementation

#### Data Ingestion
```python
# Download configuration
START_YEAR = 2025
START_MONTH = 1
END_YEAR = 2025
END_MONTH = 12
CITIES = ['NYC']

# Download process
for source in sources:
    response = requests.get(source['url'])
    with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
        zip_ref.extractall(landing_path)
```

#### Bronze Processing
```python
# Schema validation
bronze_df = spark.read.csv(file_path)
    .withColumn("started_at", F.to_timestamp("started_at"))
    .withColumn("ended_at", F.to_timestamp("ended_at"))

# Quality checks
quality_metrics = log_data_quality(bronze_df, "bronze_validation")
```

#### Silver Transformations
```python
# Feature engineering
silver_df = bronze_df.withColumn(
    "ride_duration_minutes",
    F.round((F.unix_timestamp("ended_at") - 
             F.unix_timestamp("started_at")) / 60, 2)
)
```

#### Gold Analytics
```python
# Create analytics views
revenue_metrics = silver_df.groupBy("year", "month").agg(
    F.count("*").alias("total_trips"),
    F.sum("is_charged_trip").alias("charged_trips")
)
```

## Best Practices

### 1. Code Organization
- Use clear section headers
- Include documentation
- Follow consistent style
- Implement error handling

### 2. Performance
```python
# Cache intermediate results
silver_df.cache()

# Use appropriate partitioning
df.repartition("year", "month")

# Clean up resources
spark.catalog.clearCache()
```

### 3. Logging
```python
# Operation logging
logger.info("Starting data processing")
logger.spark_operation(
    "Data transformation",
    operation_type="transform",
    duration_ms=duration_ms
)
```

### 4. Error Handling
```python
try:
    process_data()
except Exception as e:
    logger.error(f"Processing failed: {str(e)}", exc_info=True)
    display(HTML(f'<div style="color: #a94442;">❌ Error: {str(e)}</div>'))
```

## Interactive Features

### 1. Progress Display
```python
# Display configuration
display(HTML(f"""
<div style="background-color: #f8f9fa; padding: 15px;">
    <p><b>Configuration:</b></p>
    <ul>
        <li>Start: {START_YEAR}-{START_MONTH:02d}</li>
        <li>End: {END_YEAR}-{END_MONTH:02d}</li>
    </ul>
</div>
"""))
```

### 2. Visualizations
```python
# Create visualizations
plt.figure(figsize=(12, 6))
sns.barplot(data=summary_df, x='month', y='total_trips')
plt.title('Monthly Trip Distribution')
plt.show()
```

### 3. Data Exploration
```python
# Display sample data
display(df.limit(5).toPandas())

# Show summary statistics
display(df.describe().toPandas())
```

## Development Workflow

### 1. Setup
1. Start Jupyter Lab
2. Open `nycbs.ipynb`
3. Configure parameters
4. Initialize logging

### 2. Development
1. Write code in cells
2. Test incrementally
3. Document changes
4. Handle errors

### 3. Execution
1. Clear all outputs
2. Restart kernel
3. Run all cells
4. Verify results

## Debugging

### 1. Cell Execution
```python
# Add debug logging
logger.debug(f"DataFrame shape: {df.count(), len(df.columns)}")

# Display intermediate results
display(df.select("column_name").show())
```

### 2. Error Investigation
```python
# Catch and display errors
try:
    result = process_data()
except Exception as e:
    logger.error("Processing failed", error=e)
    display(HTML(f'<div style="color: red;">Error: {str(e)}</div>'))
```

### 3. Performance Analysis
```python
# Monitor execution time
start_time = time.time()
result = operation()
duration = time.time() - start_time
logger.info(f"Operation took {duration:.2f} seconds")
```

## Maintenance

### 1. Code Updates
1. Document changes
2. Test modifications
3. Update comments
4. Verify pipeline

### 2. Performance Optimization
1. Monitor execution times
2. Optimize queries
3. Update caching
4. Clean resources

### 3. Error Handling
1. Review error logs
2. Update error handling
3. Add recovery steps
4. Test edge cases

## Related Documentation

- [Data Pipeline](../3_data_pipeline/architecture.md)
- [Monitoring](../5_operations/monitoring.md)
- [Troubleshooting](../6_troubleshooting/common_issues.md) 