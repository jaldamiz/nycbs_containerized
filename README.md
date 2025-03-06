# NYC Bike Share Data Analysis

A containerized data analytics platform for NYC Bike Share data using Apache Spark, Delta Lake, and ELK Stack.

## 🚀 Features

- **Data Lake Architecture**
  - Landing zone for raw data ingestion
  - Bronze layer for validated data
  - Silver layer for enriched data
  - Gold layer for analytics-ready views

- **Analytics & Visualization**
  - Interactive Streamlit dashboard
  - Jupyter notebooks for analysis
  - Real-time metrics and KPIs
  - Geospatial visualizations

- **Monitoring & Logging**
  - ELK Stack integration (Elasticsearch, Logstash, Kibana)
  - Structured logging with context
  - Performance monitoring
  - Query analytics

## 🏗️ Architecture

```
nycbs_containerized/
├── conf/                    # Configuration files
│   ├── logstash/           # Logstash pipeline configs
│   ├── spark-defaults.conf # Spark configuration
│   └── log4j.properties   # Logging configuration
├── src/                   # Source code
│   ├── dashboard/        # Streamlit dashboard
│   ├── notebooks/       # Jupyter notebooks
│   └── utils/          # Shared utilities
├── data/               # Data directories (mounted volumes)
│   ├── landing/       # Raw data ingestion
│   ├── bronze/        # Validated data
│   ├── silver/        # Enriched data
│   └── gold/          # Analytics views
└── documentation/     # Project documentation
```

## 🛠️ Setup

### Prerequisites
- Docker and Docker Compose
- Git
- 8GB+ RAM recommended

### Quick Start
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/nycbs_containerized.git
   cd nycbs_containerized
   ```

2. Create required Docker volumes:
   ```bash
   docker volume create nycbs_data_landing
   docker volume create nycbs_data_bronze
   docker volume create nycbs_data_silver
   docker volume create nycbs_data_gold
   docker volume create nycbs_warehouse
   ```

3. Start the services:
   ```bash
   docker-compose up -d
   ```

4. Access the services:
   - Jupyter Lab: http://localhost:8888
   - Streamlit Dashboard: http://localhost:8501
   - Kibana: http://localhost:5601

## 📊 Data Pipeline

1. **Data Ingestion** (`nycbs.ipynb`)
   - Downloads CitiBike trip data
   - Validates file integrity
   - Tracks processing status

2. **Bronze Layer**
   - Raw data preservation
   - Schema enforcement
   - Quality checks

3. **Silver Layer**
   - Data enrichment
   - Feature engineering
   - Time and distance calculations

4. **Gold Layer**
   - Analytics views
   - Aggregated metrics
   - Business KPIs

## 📈 Analytics Dashboard

The Streamlit dashboard (`src/dashboard/app.py`) provides:
- Revenue analysis
- Station utilization
- Temporal patterns
- Route analytics

## 🔍 Monitoring

- **Logging**: Structured logging with ELK Stack
- **Metrics**: Query performance and data quality
- **Alerts**: Error tracking and notifications

## 🤝 Contributing

1. Follow the directory structure
2. Use provided utilities for logging
3. Maintain data quality checks
4. Document changes and features

## 📝 Best Practices

- Use environment variables for configuration
- Follow the medallion architecture
- Implement proper error handling
- Maintain code documentation

## 📚 Documentation

Detailed documentation available in `/documentation`:
- `architecture.md`: System design and components
- `data.md`: Data model and pipeline
- `logging.md`: Logging and monitoring
- `project_structure.md`: Code organization
- `SERVICE_CATALOG.md`: Service inventory 