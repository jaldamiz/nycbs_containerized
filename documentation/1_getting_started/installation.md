# Installation Guide

## Prerequisites

### System Requirements
- 8GB+ RAM recommended
- 20GB+ free disk space
- Docker Desktop
- Git

### Software Versions
- Docker Engine 24.0+
- Docker Compose 2.0+
- Git 2.0+

## Installation Steps

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/nycbs_containerized.git
cd nycbs_containerized
```

### 2. Create Docker Volumes
```bash
# Create data volumes
docker volume create nycbs_data_landing
docker volume create nycbs_data_bronze
docker volume create nycbs_data_silver
docker volume create nycbs_data_gold
docker volume create nycbs_warehouse

# Create log volumes
docker volume create nycbs_streamlit_logs
docker volume create nycbs_jupyter_logs
docker volume create nycbs_spark_logs
docker volume create nycbs_delta_logs
```

### 3. Start Services
```bash
# Start all services
docker-compose up -d

# Verify services are running
docker-compose ps
```

### 4. Access Services

#### Jupyter Lab
- URL: http://localhost:8888
- Token: Check console output or use environment variable

#### Streamlit Dashboard
- URL: http://localhost:8501
- No authentication required

#### Kibana
- URL: http://localhost:5601
- No authentication required

## Configuration

### Environment Variables
Create a `.env` file in the project root:
```env
JUPYTER_TOKEN=your_token_here
MAPBOX_TOKEN=your_mapbox_token  # Optional, for maps
```

### Resource Allocation
Adjust Docker resource limits in `docker-compose.yml`:
```yaml
services:
  spark-iceberg:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
```

## Verification

### 1. Check Container Health
```bash
# Check all containers
docker-compose ps

# Check specific logs
docker-compose logs spark-iceberg
docker-compose logs elasticsearch
```

### 2. Verify Data Volumes
```bash
# List volumes
docker volume ls | grep nycbs

# Inspect volume
docker volume inspect nycbs_data_landing
```

### 3. Test Services
1. Open Jupyter Lab
   - Create new notebook
   - Run: `print("Hello, NYC Bike Share!")`

2. Open Streamlit Dashboard
   - Check if metrics load
   - Verify visualizations

3. Check Kibana
   - Open Kibana URL
   - Verify indices are created

## Common Setup Issues

### 1. Resource Limits
**Problem**: Containers fail to start due to memory limits
**Solution**: Increase Docker memory allocation in Docker Desktop settings

### 2. Port Conflicts
**Problem**: Services fail due to port conflicts
**Solution**: Modify port mappings in `docker-compose.yml`

### 3. Volume Permissions
**Problem**: Permission denied errors
**Solution**: Check volume ownership and permissions

## Next Steps

1. [Project Overview](overview.md)
2. [Data Pipeline Setup](../3_data_pipeline/architecture.md)
3. [Dashboard Guide](../4_analytics/dashboard.md)

## Support

For issues:
1. Check [Common Issues](../6_troubleshooting/common_issues.md)
2. Run [Health Checks](../6_troubleshooting/health_checks.md)
3. Review container logs 