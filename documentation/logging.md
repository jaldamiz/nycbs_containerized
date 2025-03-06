# NYCBS Logging Structure

## Directory Structure
```
/var/log/nycbs/
├── streamlit/              # Streamlit application logs
│   ├── error/
│   │   └── streamlit.log  # Error-level logs
│   └── info/
│       └── streamlit.log  # Info-level logs
├── jupyter/               # Jupyter notebook logs
│   ├── error/
│   │   └── error.log     # Error-level logs
│   └── jupyter.log       # Main notebook logs
├── spark/                # Spark execution logs
│   └── spark.log        # Spark operations
└── delta/               # Delta Lake logs
    └── operations.log   # Delta table operations
```

## Elasticsearch Indices
- `nycbs-app-*`: Streamlit application logs
- `nycbs-notebook-*`: Jupyter notebook execution logs
- `nycbs-spark-*`: Spark operation logs
- `nycbs-delta-*`: Delta Lake operation logs
- `nycbs-other-*`: Other application logs

## Log Types and Fields

### Common Fields (All Logs)
- `timestamp`: ISO8601 formatted timestamp
- `level`: Log level (INFO, ERROR, etc.)
- `message`: Log message
- `environment`: Production/Development
- `cluster_name`: Cluster identifier

### Application Logs (Streamlit)
- `event_category`: Type of event (data_load, error, etc.)
- `duration_ms`: Operation duration in milliseconds
- `data_size`: Size of processed data
- `error_occurred`: Boolean flag for errors
- `needs_investigation`: Flag for issues needing attention

### Notebook Logs (Jupyter)
- `notebook_name`: Name of the notebook
- `cell_type`: Type of cell (code, markdown)
- `execution_count`: Cell execution number
- `user`: User executing the notebook

### Spark Logs
- `operation_type`: Type of Spark operation
- `duration_ms`: Operation duration
- `data_size`: Size of processed data

### Delta Logs
- `operation_type`: Type of Delta operation
- `table_name`: Name of the Delta table
- `schema_changes`: Boolean for schema modifications
- `data_operation`: Boolean for data modifications

## Error Tracking
Errors are classified by severity:
- `high`: Connection/timeout issues
- `medium`: Validation/warning issues
- `low`: Other issues

## Performance Monitoring
Operations are flagged as slow if:
- `duration_ms > 1000` (1 second threshold)
- Tracked in `performance.is_slow` field

## Log Rotation
- File size limit: 100MB
- Backup count: 10 files
- Rotation: Daily with timestamp 

# Create index pattern
curl -X POST "localhost:5601/api/saved_objects/index-pattern/notebook-logs-*" -H "kbn-xsrf: true" -H "Content-Type: application/json" -d @kibana_dashboards.ndjson

# Create dashboard
curl -X POST "localhost:5601/api/saved_objects/dashboard/notebook-dashboard" -H "kbn-xsrf: true" -H "Content-Type: application/json" -d @kibana_dashboards.ndjson 