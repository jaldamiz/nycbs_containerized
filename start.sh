#!/bin/bash
set -e

# Function to check if a directory is empty
is_empty() {
    [ -z "$(ls -A $1)" ]
}

# Initialize directories if empty
for dir in data/{landing,bronze,silver,gold} warehouse/{temp,checkpoints,eventlogs,logs}; do
    if is_empty "/home/aldamiz/$dir"; then
        echo "Initializing directory: /home/aldamiz/$dir"
        chown aldamiz:aldamiz "/home/aldamiz/$dir"
        chmod 770 "/home/aldamiz/$dir"
    fi
done

# Ensure log files exist with proper permissions
for logfile in NYCBS_CONTAINERIZED spark etl data analysis jupyter streamlit supervisord; do
    touch "/home/aldamiz/warehouse/logs/$logfile.log"
    chown aldamiz:aldamiz "/home/aldamiz/warehouse/logs/$logfile.log"
    chmod 660 "/home/aldamiz/warehouse/logs/$logfile.log"
done

for errfile in jupyter streamlit; do
    touch "/home/aldamiz/warehouse/logs/$errfile.err"
    chown aldamiz:aldamiz "/home/aldamiz/warehouse/logs/$errfile.err"
    chmod 660 "/home/aldamiz/warehouse/logs/$errfile.err"
done

# Ensure supervisor socket directory exists with proper permissions
mkdir -p /var/run/supervisor
chown -R aldamiz:aldamiz /var/run/supervisor
chmod -R 770 /var/run/supervisor

# Start supervisor
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf 