import logging
import json
from datetime import datetime
import socket
import os

class NotebookLogHandler(logging.Handler):
    """Custom handler to send logs to Logstash via TCP"""
    def __init__(self, host='logstash', port=5000):
        super().__init__()
        self.host = host
        self.port = port
        self.sock = None
        self._connect()

    def _connect(self):
        """Establish connection to Logstash"""
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.connect((self.host, self.port))
        except Exception:
            self.sock = None

    def emit(self, record):
        """Send log record to Logstash"""
        if self.sock is None:
            self._connect()
        if self.sock is None:
            return  # Skip if connection failed

        # Create log entry
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'app': 'jupyter-notebook',
            'level': record.levelname,
            'message': record.getMessage(),
            'logger': record.name,
            'path': record.pathname,
            'function': record.funcName,
            'line_number': record.lineno,
            'user': os.getenv('NB_USER', 'unknown'),
            'container': os.getenv('HOSTNAME', 'unknown'),
            'notebook': getattr(record, 'notebook', 'unknown'),
            'cell_id': getattr(record, 'cell_id', 'unknown'),
            'execution_count': getattr(record, 'execution_count', -1),
            'duration_ms': getattr(record, 'duration_ms', None),
            'memory_usage_mb': getattr(record, 'memory_usage_mb', None),
            'error_type': getattr(record, 'error_type', None),
            'error_details': getattr(record, 'error_details', None)
        }

        try:
            # Send log entry to Logstash
            self.sock.sendall((json.dumps(log_entry) + '\n').encode())
        except Exception:
            self.sock = None  # Reset connection on error

def setup_notebook_logging():
    """Configure logging for notebook operations"""
    logger = logging.getLogger('notebook_logger')
    logger.setLevel(logging.INFO)
    
    # Clear any existing handlers
    logger.handlers = []
    
    # Add Logstash handler
    logstash_handler = NotebookLogHandler()
    logstash_handler.setLevel(logging.INFO)
    logger.addHandler(logstash_handler)
    
    # Add console handler for development
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    logger.addHandler(console_handler)
    
    return logger

# Create logger instance
logger = setup_notebook_logging() 