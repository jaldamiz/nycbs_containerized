# Troubleshooting Guide

## Common Issues and Solutions

### Container Issues

#### 1. Container Startup Failures
**Problem**: Containers fail to start or restart continuously
```bash
# Check container status
docker-compose ps

# View container logs
docker-compose logs [service_name]
```

**Solutions**:
1. Check resource limits in Docker Desktop
2. Verify port availability
3. Check volume permissions
4. Review service dependencies

#### 2. Resource Constraints
**Problem**: Services crash due to memory/CPU limits
```bash
# Check resource usage
docker stats

# View memory limits
docker-compose config
```

**Solutions**:
1. Increase Docker memory allocation
2. Adjust service resource limits
3. Optimize Spark configurations
4. Clean up unused resources

#### 3. Volume Permissions
**Problem**: Permission denied errors for mounted volumes
```bash
# Check volume permissions
docker exec -u root [container] ls -la /path/to/volume

# Fix permissions
docker exec -u root [container] chown -R user:group /path/to/volume
```

**Solutions**:
1. Set correct ownership
2. Adjust file permissions
3. Verify user mapping
4. Check volume mounts

### Data Pipeline Issues

#### 1. Data Ingestion Failures
**Problem**: Unable to download or process source files
```python
# Check file availability
response = requests.head(source_url)
print(response.status_code)

# Verify local storage
os.path.exists(file_path)
```

**Solutions**:
1. Verify source URL
2. Check network connectivity
3. Ensure sufficient storage
4. Review file permissions

#### 2. Processing Errors
**Problem**: Data transformation or validation failures
```python
# Check data quality
quality_metrics = log_data_quality(df, "validation")

# Review error logs
logger.error("Processing failed", error=e)
```

**Solutions**:
1. Validate input data
2. Check schema compatibility
3. Review transformation logic
4. Increase timeout limits

#### 3. Delta Table Issues
**Problem**: Delta table corruption or access errors
```sql
-- Check table health
DESCRIBE HISTORY delta.`/path/to/table`

-- Restore to previous version
RESTORE TABLE delta.`/path/to/table` TO VERSION AS OF 1
```

**Solutions**:
1. Vacuum old versions
2. Optimize table
3. Rebuild from source
4. Check permissions

### Monitoring Issues

#### 1. Logging Pipeline
**Problem**: Logs not appearing in Kibana
```bash
# Check Logstash status
nc -zv localhost 5000

# View Logstash logs
docker-compose logs logstash
```

**Solutions**:
1. Verify Logstash configuration
2. Check TCP connection
3. Review log permissions
4. Restart logging pipeline

#### 2. Elasticsearch Issues
**Problem**: Index failures or search errors
```bash
# Check cluster health
curl -X GET "localhost:9200/_cluster/health"

# View indices
curl -X GET "localhost:9200/_cat/indices"
```

**Solutions**:
1. Check disk space
2. Verify index settings
3. Clear old indices
4. Restart Elasticsearch

#### 3. Kibana Access
**Problem**: Unable to access Kibana dashboard
```bash
# Check Kibana status
curl -f http://localhost:5601/api/status

# View Kibana logs
docker-compose logs kibana
```

**Solutions**:
1. Verify port mapping
2. Check Elasticsearch connection
3. Clear browser cache
4. Restart Kibana

### Dashboard Issues

#### 1. Data Loading
**Problem**: Dashboard fails to load data
```python
# Check data access
try:
    df = spark.read.format("delta").load(table_path)
except Exception as e:
    st.error(f"Data loading failed: {str(e)}")
```

**Solutions**:
1. Verify data paths
2. Check permissions
3. Review cache settings
4. Clear Streamlit cache

#### 2. Visualization Errors
**Problem**: Charts fail to render
```python
# Debug visualization
try:
    fig = create_visualization(data)
    st.plotly_chart(fig)
except Exception as e:
    st.error(f"Visualization failed: {str(e)}")
```

**Solutions**:
1. Check data format
2. Verify data types
3. Review chart configuration
4. Update dependencies

#### 3. Performance Issues
**Problem**: Slow dashboard response
```python
# Monitor performance
start_time = time.time()
result = operation()
st.write(f"Operation took {time.time() - start_time:.2f}s")
```

**Solutions**:
1. Implement caching
2. Optimize queries
3. Reduce data size
4. Use data aggregation

### Recovery Procedures

#### 1. Data Recovery
```python
# Restore Delta table
spark.sql(f"""
    RESTORE TABLE delta.`{table_path}`
    TO TIMESTAMP AS OF {timestamp}
""")
```

#### 2. Service Recovery
```bash
# Restart specific service
docker-compose restart [service]

# Rebuild service
docker-compose up -d --build [service]
```

#### 3. Full System Recovery
```bash
# Stop all services
docker-compose down

# Clean up resources
docker system prune

# Rebuild and start
docker-compose up -d --build
```

## Health Check Scripts

### 1. System Health
```bash
#!/bin/bash
# Check all services
docker-compose ps

# Check resource usage
docker stats --no-stream

# View recent errors
docker-compose logs --tail=100 | grep ERROR
```

### 2. Data Health
```python
def check_data_health():
    """Verify data pipeline health"""
    try:
        # Check tables
        tables = spark.catalog.listTables()
        
        # Verify recent data
        recent_data = check_recent_data()
        
        # Log results
        logger.info("Health check complete", 
                   extra={"status": "healthy"})
    except Exception as e:
        logger.error("Health check failed", error=e)
```

### 3. Monitoring Health
```bash
#!/bin/bash
# Check ELK stack
curl -f http://localhost:9200/_cluster/health
curl -f http://localhost:5601/api/status
nc -zv localhost 5000

# Check log files
ls -la /var/log/nycbs/**/*.log
```

## Related Documentation

- [Monitoring Setup](../5_operations/monitoring.md)
- [Maintenance Tasks](../5_operations/maintenance.md)
- [Health Checks](health_checks.md) 