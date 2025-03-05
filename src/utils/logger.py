import logging
import os
from datetime import datetime
from logging.handlers import RotatingFileHandler
import json
import traceback

class JSONFormatter(logging.Formatter):
    """Custom JSON formatter for ELK compatibility"""
    def format(self, record):
        log_record = {
            'timestamp': datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3],
            'level': record.levelname,
            'logger_name': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line_number': record.lineno
        }
        
        # Add exception info if present
        if record.exc_info:
            log_record['exception'] = {
                'type': record.exc_info[0].__name__,
                'message': str(record.exc_info[1]),
                'stacktrace': traceback.format_exception(*record.exc_info)
            }
            
        # Add extra fields if present
        if hasattr(record, 'extra_fields'):
            log_record.update(record.extra_fields)
            
        return json.dumps(log_record)

def setup_logger(name, log_file=None, level=logging.INFO):
    """
    Set up a logger with both file and console handlers.
    
    Args:
        name (str): Logger name
        log_file (str, optional): Path to log file. If None, uses default path
        level (int): Logging level (default: logging.INFO)
    
    Returns:
        logging.Logger: Configured logger instance
    """
    # Create logger
    logger = logging.getLogger(name)
    logger.setLevel(level)
    
    # Create formatters
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    # Create console handler
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # Create file handler if log_file is specified
    if log_file:
        # Ensure log directory exists
        log_dir = os.path.dirname(log_file)
        if log_dir:
            os.makedirs(log_dir, exist_ok=True)
        
        # Create rotating file handler
        file_handler = RotatingFileHandler(
            log_file,
            maxBytes=100*1024*1024,  # 100MB
            backupCount=10
        )
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    
    return logger

def setup_elk_logger(name, log_file_path):
    """Set up a logger with JSON formatting for ELK"""
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    
    # Create file handler
    fh = logging.FileHandler(log_file_path)
    fh.setLevel(logging.INFO)
    
    # Create JSON formatter
    formatter = JSONFormatter()
    fh.setFormatter(formatter)
    
    # Add handler to logger
    logger.addHandler(fh)
    
    return logger

def get_etl_logger():
    """Get logger for ETL operations."""
    return setup_elk_logger('etl', '/var/log/nycbs/etl.log')

def get_data_logger():
    """Get logger for data operations."""
    return setup_elk_logger('data', '/var/log/nycbs/data_quality.log')

def get_analysis_logger():
    """Get logger for analysis operations."""
    return setup_elk_logger('analysis', '/var/log/nycbs/analysis.log')

# Helper function to add context to logs
def log_with_context(logger, level, message, **context):
    """Add additional context to log messages"""
    extra = {'extra_fields': context}
    logger.log(level, message, extra=extra)

# Example usage:
if __name__ == '__main__':
    # Get loggers
    etl_logger = get_etl_logger()
    data_logger = get_data_logger()
    analysis_logger = get_analysis_logger()
    
    # Test logging
    etl_logger.info("ETL process started")
    data_logger.debug("Reading data from source")
    analysis_logger.warning("Missing data in analysis") 