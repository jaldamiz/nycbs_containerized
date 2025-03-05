# Use PySpark notebook as base (includes ZMQ properly configured)
FROM jupyter/pyspark-notebook:python-3.10

USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        git \
        logrotate \
        supervisor \
        build-essential \
        cmake \
        pkg-config \
        libssl-dev \
        libffi-dev \
        python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and organize JARs with proper permissions
RUN mkdir -p /usr/local/spark/jars && \
    # Delta Lake JARs
    wget -P /usr/local/spark/jars/ https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.4.0/delta-core_2.12-2.4.0.jar && \
    wget -P /usr/local/spark/jars/ https://repo1.maven.org/maven2/io/delta/delta-storage/2.4.0/delta-storage-2.4.0.jar && \
    # Iceberg JARs
    wget -P /usr/local/spark/jars/ https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.4_2.12/1.3.1/iceberg-spark-runtime-3.4_2.12-1.3.1.jar && \
    # Set proper permissions
    chown -R root:root /usr/local/spark/jars && \
    chmod -R 755 /usr/local/spark/jars

# Rename jovyan user to aldamiz (keeping UID 1000)
RUN usermod -l aldamiz jovyan && \
    groupmod -n aldamiz users && \
    usermod -d /home/aldamiz -m aldamiz && \
    ln -s /home/aldamiz /home/jovyan

# Create required directories
RUN mkdir -p /home/aldamiz/conf \
             /home/aldamiz/src/{utils,dashboard} \
             /home/aldamiz/data/{landing,bronze,silver,gold} \
             /home/aldamiz/warehouse/{temp,checkpoints,eventlogs,logs} \
             /home/aldamiz/.local/share/jupyter/runtime \
             /var/run/supervisor \
             /var/log/supervisor

# Create log files with proper permissions
RUN touch /home/aldamiz/warehouse/logs/{nycbs,spark,etl,data,analysis,jupyter,streamlit,supervisord}.log && \
    touch /home/aldamiz/warehouse/logs/{jupyter,streamlit}.err && \
    chown -R aldamiz:aldamiz /home/aldamiz/warehouse/logs && \
    chmod 660 /home/aldamiz/warehouse/logs/*.log && \
    chmod 660 /home/aldamiz/warehouse/logs/*.err && \
    chmod 770 /home/aldamiz/warehouse/logs

# Copy requirements file and install dependencies
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# Set up permissions
RUN chown -R aldamiz:aldamiz /home/aldamiz && \
    chmod 750 /home/aldamiz && \
    find /home/aldamiz/data -type d -exec chmod 770 {} \; && \
    find /home/aldamiz/warehouse -type d -exec chmod 770 {} \; && \
    chmod 750 /home/aldamiz/conf && \
    chmod 750 /home/aldamiz/src && \
    chmod 750 /home/aldamiz/src/utils && \
    chown -R root:root /usr/local/spark && \
    chmod -R 755 /usr/local/spark && \
    chown -R aldamiz:aldamiz /var/run/supervisor && \
    chmod -R 770 /var/run/supervisor && \
    chown -R aldamiz:aldamiz /var/log/supervisor && \
    chmod -R 770 /var/log/supervisor

# Copy configurations and utilities
COPY --chown=aldamiz:aldamiz conf/spark-defaults.conf /home/aldamiz/conf/
COPY --chown=aldamiz:aldamiz conf/log4j.properties /home/aldamiz/conf/
COPY --chown=aldamiz:aldamiz conf/logrotate.conf /etc/logrotate.d/nycbs
COPY --chown=aldamiz:aldamiz src/utils/logger.py /home/aldamiz/src/utils/
COPY --chown=aldamiz:aldamiz src/dashboard /home/aldamiz/src/dashboard
COPY --chown=aldamiz:aldamiz init_spark.py /home/aldamiz/

# Setup supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set file permissions
RUN find /home/aldamiz/conf -type f -exec chmod 640 {} \; && \
    find /home/aldamiz/src -type f -exec chmod 640 {} \; && \
    echo "aldamiz soft nofile 65536" >> /etc/security/limits.conf && \
    echo "aldamiz hard nofile 65536" >> /etc/security/limits.conf

# Set environment variables
ENV PYTHONPATH=$PYTHONPATH:/usr/local/spark/python:/usr/local/spark/python/lib/py4j-0.10.9.5-src.zip:/home/aldamiz/src \
    SPARK_CONF_DIR=/home/aldamiz/conf \
    SPARK_LOCAL_IP=0.0.0.0 \
    SPARK_MASTER_HOST=0.0.0.0 \
    DATA_DIR=/home/aldamiz/data \
    WAREHOUSE_DIR=/home/aldamiz/warehouse \
    LOG_DIR=/home/aldamiz/warehouse/logs \
    JUPYTER_TOKEN=63d106cc392403e80ab48013f73a6077e67035f64c6bf8e4 \
    NB_USER=aldamiz \
    NB_UID=1000 \
    NB_GID=1000 \
    HOME=/home/aldamiz \
    JUPYTER_RUNTIME_DIR=/home/aldamiz/.local/share/jupyter/runtime

# Expose ports
EXPOSE 8888 4040 8501

# Create startup script
COPY --chown=root:root start.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/start.sh

# Health check for both services
HEALTHCHECK --interval=5s --timeout=3s --start-period=15s --retries=3 \
    CMD curl -f "http://localhost:8888/api/status?token=${JUPYTER_TOKEN}" && \
        curl -f "http://localhost:8501/_stcore/health" || exit 1

# Start supervisor to manage both services
CMD ["/usr/local/bin/start.sh"]