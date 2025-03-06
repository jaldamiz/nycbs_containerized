# Health Checks Documentation

## Overview

This document outlines the health check procedures for the NYC Bike Share Analytics platform. Regular health checks ensure system reliability and early problem detection.

## System Health

### 1. Container Health
```bash
#!/bin/bash
# Check container status
docker-compose ps

# Check specific container
docker inspect --format='{{.State.Health.Status}}' [container_name]

# View resource usage
docker stats --no-stream
```

### 2. Resource Monitoring
```python
def check_system_resources():
    """Monitor system resource usage"""
    metrics = {
        "cpu_percent": psutil.cpu_percent(),
        "memory_percent": psutil.virtual_memory().percent,
        "disk_usage": psutil.disk_usage('/').percent
    }
    
    # Log metrics
    logger.info("System metrics", extra=metrics)
    
    # Alert if thresholds exceeded
    if metrics["memory_percent"] > 85:
        alert_admin("High memory usage")
```

### 3. Network Connectivity
```bash
# Check service ports
nc -zv localhost 8888  # Jupyter
nc -zv localhost 8501  # Streamlit
nc -zv localhost 9200  # Elasticsearch

# Test internal network
docker network inspect nycbs_network
```

## Data Pipeline Health

### 1. Data Freshness
```python
def check_data_freshness():
    """Verify data is being updated"""
    try:
        # Check latest data
        latest = spark.read.format("delta").load(gold_path) \
            .agg(F.max("processing_date").alias("latest_date")) \
            .collect()[0]["latest_date"]
        
        # Check delay
        delay = datetime.now() - latest
        if delay.total_seconds() > 86400:  # 24 hours
            alert_admin(f"Data is {delay.total_seconds()/3600:.1f} hours old")
            
    except Exception as e:
        logger.error("Data freshness check failed", error=e)
```

### 2. Data Quality
```python
def check_data_quality():
    """Verify data quality metrics"""
    metrics = {
        "null_count": get_null_counts(),
        "duplicate_count": get_duplicate_count(),
        "validation_errors": get_validation_errors()
    }
    
    # Log metrics
    logger.info("Data quality metrics", extra=metrics)
    
    # Alert on issues
    if metrics["validation_errors"] > 0:
        alert_admin("Data quality issues detected")
```

### 3. Processing Status
```python
def check_processing_status():
    """Monitor data processing pipeline"""
    control_df = spark.read.format("delta").load(control_table_path)
    
    # Check for failures
    failures = control_df.filter(F.col("status") == "FAILED")
    if failures.count() > 0:
        alert_admin("Processing failures detected")
```

## Service Health

### 1. ELK Stack
```bash
#!/bin/bash
# Check Elasticsearch
curl -f http://localhost:9200/_cluster/health

# Check Logstash
curl -f http://localhost:9600

# Check Kibana
curl -f http://localhost:5601/api/status
```

### 2. Spark Services
```python
def check_spark_health():
    """Verify Spark cluster health"""
    try:
        # Test Spark session
        spark.sql("SELECT 1").collect()
        
        # Check active executors
        sc.statusTracker().getExecutorInfos()
        
    except Exception as e:
        logger.error("Spark health check failed", error=e)
```

### 3. Dashboard Services
```python
def check_dashboard_health():
    """Verify dashboard services"""
    try:
        # Check Streamlit
        requests.get("http://localhost:8501/_stcore/health")
        
        # Check data access
        load_dashboard_data()
        
    except Exception as e:
        logger.error("Dashboard health check failed", error=e)
```

## Storage Health

### 1. Volume Status
```bash
# Check volume usage
docker system df -v

# Check specific volumes
docker volume inspect nycbs_data_landing
docker volume inspect nycbs_warehouse
```

### 2. Delta Tables
```python
def check_delta_tables():
    """Verify Delta table health"""
    for table in delta_tables:
        # Check table history
        history = spark.sql(f"DESCRIBE HISTORY {table}")
        
        # Verify optimization status
        metrics = spark.sql(f"DESCRIBE DETAIL {table}")
        
        # Check for issues
        if needs_optimization(metrics):
            schedule_optimization(table)
```

### 3. Log Storage
```bash
# Check log sizes
du -h /var/log/nycbs/*

# Verify rotation
logrotate -d /etc/logrotate.d/nycbs

# Check permissions
ls -la /var/log/nycbs/
```

## Performance Health

### 1. Query Performance
```python
def monitor_query_performance():
    """Track query execution times"""
    metrics = spark.read.format("delta").load(metrics_path)
    
    # Analyze slow queries
    slow_queries = metrics.filter(F.col("duration_ms") > threshold)
    
    # Generate report
    if slow_queries.count() > 0:
        generate_performance_report(slow_queries)
```

### 2. Resource Usage
```python
def track_resource_usage():
    """Monitor resource utilization"""
    metrics = {
        "memory_usage": get_memory_usage(),
        "disk_io": get_disk_io_stats(),
        "network_io": get_network_stats()
    }
    
    # Log metrics
    logger.info("Resource usage", extra=metrics)
```

### 3. Response Times
```python
def check_response_times():
    """Monitor service response times"""
    endpoints = {
        "dashboard": "http://localhost:8501",
        "jupyter": "http://localhost:8888",
        "elasticsearch": "http://localhost:9200"
    }
    
    for service, url in endpoints.items():
        response_time = measure_response_time(url)
        if response_time > thresholds[service]:
            alert_admin(f"Slow response from {service}")
```

## Automated Checks

### 1. Health Check Script
```python
def run_health_checks():
    """Execute all health checks"""
    checks = [
        check_system_resources,
        check_data_freshness,
        check_data_quality,
        check_processing_status,
        check_spark_health,
        check_dashboard_health
    ]
    
    results = []
    for check in checks:
        try:
            result = check()
            results.append((check.__name__, "SUCCESS"))
        except Exception as e:
            results.append((check.__name__, f"FAILED: {str(e)}"))
            
    return generate_health_report(results)
```

### 2. Scheduling
```bash
# crontab entries
*/5 * * * * /usr/local/bin/health_checks/quick_check.sh
0 * * * * /usr/local/bin/health_checks/hourly_check.sh
0 0 * * * /usr/local/bin/health_checks/daily_check.sh
```

### 3. Alerting
```python
def alert_admin(message, severity="warning"):
    """Send alerts for health issues"""
    alert = {
        "message": message,
        "severity": severity,
        "timestamp": datetime.now().isoformat(),
        "system": "NYC Bike Share Analytics"
    }
    
    # Log alert
    logger.warning("Health check alert", extra=alert)
    
    # Send notification
    send_notification(alert)
```

## Related Documentation

- [Maintenance Tasks](../5_operations/maintenance.md)
- [Monitoring Setup](../5_operations/monitoring.md)
- [Troubleshooting Guide](common_issues.md) 