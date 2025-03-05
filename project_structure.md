# Project Directory Structure and Docker Volume Mapping

## 1. Application Logging Paths

### Streamlit Dashboard (`app.py`)
- **Log Directory**: `/var/log/nycbs/streamlit`
  - Info logs: `/var/log/nycbs/streamlit/info/streamlit.log`
  - Error logs: `/var/log/nycbs/streamlit/error/streamlit.log`
- **Docker Volume**: `streamlit_logs`
- **Permissions**: 770 for directories, 660 for log files
- **Owner**: 1000:1000 (aldamiz:aldamiz)

### Jupyter Notebook (`nycbs.ipynb`)
- **Log Directory**: `/var/log/nycbs/jupyter`
  - Main log: `/var/log/nycbs/jupyter/jupyter.log`
  - Error log: `/var/log/nycbs/jupyter/error/error.log`
- **Docker Volume**: `jupyter_logs`
- **Permissions**: 770 for directories, 660 for log files
- **Owner**: 1000:1000 (aldamiz:aldamiz)

### General Logging (`logger.py`)
- **Log Files**:
  - ETL logs: `/var/log/nycbs/etl.log`
  - Data quality logs: `/var/log/nycbs/data_quality.log`
  - Analysis logs: `/var/log/nycbs/analysis.log`
- **Docker Volume**: `delta_logs`

## 2. Data Lake Structure

### Base Directory: `/home/aldamiz/data`
- **Docker Volume**: `data_landing`
  - Path: `/home/aldamiz/data/landing`
  - Purpose: Raw data ingestion
  - Permissions: 770
  - Owner: 1000:1000

- **Docker Volume**: `data_bronze`
  - Path: `/home/aldamiz/data/bronze`
  - Purpose: Raw data storage
  - Permissions: 770
  - Owner: 1000:1000

- **Docker Volume**: `data_silver`
  - Path: `/home/aldamiz/data/silver`
  - Purpose: Cleaned and transformed data
  - Permissions: 770
  - Owner: 1000:1000

- **Docker Volume**: `data_gold`
  - Path: `/home/aldamiz/data/gold`
  - Purpose: Business-ready data
  - Permissions: 770
  - Owner: 1000:1000

## 3. Warehouse Structure

### Base Directory: `/home/aldamiz/warehouse`
- **Docker Volume**: `warehouse`
  - Subdirectories:
    - `/home/aldamiz/warehouse/temp`
    - `/home/aldamiz/warehouse/checkpoints`
    - `/home/aldamiz/warehouse/eventlogs`
    - `/home/aldamiz/warehouse/logs`
  - Permissions: 770
  - Owner: 1000:1000

## 4. Application Code Structure

### Base Directory: `/home/aldamiz/src`
- **Mounted as**: `./src:/home/aldamiz/src:ro`
- **Subdirectories**:
  - `/home/aldamiz/src/utils`
  - `/home/aldamiz/src/dashboard`
- **Permissions**: 750
- **Owner**: 1000:1000

### Configuration Directory
- **Path**: `/home/aldamiz/conf`
- **Mounted as**: `./conf:/home/aldamiz/conf:ro`
- **Permissions**: 750
- **Owner**: 1000:1000

### Notebooks Directory
- **Path**: `/home/aldamiz/notebooks`
- **Mounted as**: `./notebooks:/home/aldamiz/notebooks:rw`
- **Permissions**: 770
- **Owner**: 1000:1000

## 5. Environment Variables

### Common Environment Variables
```yaml
PYTHONPATH: /home/aldamiz/src
SPARK_CONF_DIR: /home/aldamiz/conf
DATA_DIR: /home/aldamiz/data
WAREHOUSE_DIR: /home/aldamiz/warehouse
LOG_DIR: /var/log/nycbs/streamlit
NB_USER: aldamiz
NB_UID: 1000
NB_GID: 1000
HOME: /home/aldamiz
```

## 6. Volume Mounting in Docker Compose

### Read-Write Volumes
```yaml
- streamlit_logs:/var/log/nycbs/streamlit:rw
- spark_logs:/var/log/nycbs/spark:rw
- jupyter_logs:/var/log/nycbs/jupyter:rw
- delta_logs:/var/log/nycbs/delta:rw
- data_landing:/home/aldamiz/data/landing:rw
- data_bronze:/home/aldamiz/data/bronze:rw
- data_silver:/home/aldamiz/data/silver:rw
- data_gold:/home/aldamiz/data/gold:rw
- warehouse:/home/aldamiz/warehouse:rw
```

### Read-Only Volumes
```yaml
- ./conf:/home/aldamiz/conf:ro
- ./src:/home/aldamiz/src:ro
```

### Logstash Read-Only Volumes
```yaml
- streamlit_logs:/var/log/nycbs/streamlit:ro
- spark_logs:/var/log/nycbs/spark:ro
- jupyter_logs:/var/log/nycbs/jupyter:ro
- delta_logs:/var/log/nycbs/delta:ro
``` 