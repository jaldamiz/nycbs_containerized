"""
Notebook logging utility for ELK stack integration.
Provides structured logging with both file and socket handlers,
supporting rich metadata and proper error tracking.
"""

import os
import json
import logging
import logging.handlers
from datetime import datetime
from typing import Any, Dict, Optional
from pathlib import Path

class NotebookJsonFormatter(logging.Formatter):
    """JSON formatter for ELK stack compatibility with notebook-specific fields."""
    
    def format(self, record: logging.LogRecord) -> str:
        """Format the log record as a JSON string with enhanced metadata."""
        log_obj = {
            # Basic fields
            'timestamp': datetime.utcnow().isoformat(),
            'service': 'jupyter-notebook',
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            
            # Environment info
            'user': os.getenv('NB_USER', 'unknown'),
            'container': os.getenv('HOSTNAME', 'unknown'),
            'environment': os.getenv('ENVIRONMENT', 'production'),
            
            # Notebook specific
            'notebook_name': getattr(record, 'notebook_name', 'unknown'),
            'cell_type': getattr(record, 'cell_type', 'code'),
            'execution_count': getattr(record, 'execution_count', None),
            
            # Event categorization
            'event_category': getattr(record, 'event_category', 'notebook_execution'),
            'event_type': getattr(record, 'event_type', None),
            
            # Spark specific
            'spark_job_id': getattr(record, 'spark_job_id', None),
            'operation_type': getattr(record, 'operation_type', None),
            'table_name': getattr(record, 'table_name', None),
            
            # Performance metrics
            'duration_ms': getattr(record, 'duration_ms', None),
            'memory_usage': getattr(record, 'memory_usage', None),
            'data_size': getattr(record, 'data_size', None),
            
            # Error tracking
            'error_type': getattr(record, 'error_type', None),
            'error_details': getattr(record, 'error_details', None),
            'stack_trace': getattr(record, 'stack_trace', None)
        }
        
        # Remove None values
        return json.dumps({k: v for k, v in log_obj.items() if v is not None})

class NotebookLogger:
    """Logger class for Jupyter notebooks with ELK stack integration."""
    
    def __init__(
        self,
        notebook_name: str,
        log_dir: str = "/var/log/nycbs/jupyter",
        logstash_host: str = "localhost",
        logstash_port: int = 5000,
        log_level: int = logging.INFO
    ):
        """Initialize the notebook logger with both file and socket handlers.
        
        Args:
            notebook_name: Name of the notebook for identification
            log_dir: Directory for log files
            logstash_host: Logstash host for socket connection
            logstash_port: Logstash port for socket connection
            log_level: Logging level
        """
        self.notebook_name = notebook_name
        self.log_dir = Path(log_dir)
        self.logger = logging.getLogger(f'nycbs.notebook.{notebook_name}')
        self.logger.setLevel(log_level)
        
        # Clear any existing handlers
        self.logger.handlers = []
        
        # Ensure log directories exist
        self.log_dir.mkdir(parents=True, exist_ok=True)
        (self.log_dir / "error").mkdir(exist_ok=True)
        
        # Create formatters
        json_formatter = NotebookJsonFormatter()
        console_formatter = logging.Formatter(
            '%(asctime)s - %(levelname)s - [%(name)s] - %(message)s'
        )
        
        # File handler for main logs
        main_handler = logging.handlers.RotatingFileHandler(
            self.log_dir / "jupyter.log",
            maxBytes=10485760,  # 10MB
            backupCount=5
        )
        main_handler.setFormatter(json_formatter)
        
        # File handler for errors
        error_handler = logging.handlers.RotatingFileHandler(
            self.log_dir / "error" / "error.log",
            maxBytes=10485760,  # 10MB
            backupCount=5
        )
        error_handler.setFormatter(json_formatter)
        error_handler.setLevel(logging.ERROR)
        
        # Socket handler for Logstash
        socket_handler = logging.handlers.SocketHandler(
            logstash_host,
            logstash_port
        )
        socket_handler.setFormatter(json_formatter)
        
        # Console handler for notebook output
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(console_formatter)
        
        # Add all handlers
        self.logger.addHandler(main_handler)
        self.logger.addHandler(error_handler)
        self.logger.addHandler(socket_handler)
        self.logger.addHandler(console_handler)
    
    def _get_execution_info(self) -> Dict[str, Any]:
        """Get current notebook execution information."""
        try:
            from IPython import get_ipython
            ip = get_ipython()
            if ip is not None:
                return {
                    'execution_count': ip.execution_count,
                    'cell_type': 'code'
                }
        except Exception:
            pass
        return {}
    
    def log(
        self,
        level: int,
        message: str,
        event_category: Optional[str] = None,
        **kwargs
    ) -> None:
        """Log a message with the specified level and additional context.
        
        Args:
            level: Logging level
            message: Log message
            event_category: Category of the event
            **kwargs: Additional context to include in the log
        """
        extra = {
            'notebook_name': self.notebook_name,
            'event_category': event_category,
            **self._get_execution_info(),
            **kwargs
        }
        self.logger.log(level, message, extra=extra)
    
    def info(self, message: str, **kwargs) -> None:
        """Log an info message."""
        self.log(logging.INFO, message, **kwargs)
    
    def error(self, message: str, error: Optional[Exception] = None, **kwargs) -> None:
        """Log an error message with optional exception details."""
        extra = kwargs
        if error:
            extra.update({
                'error_type': type(error).__name__,
                'error_details': str(error),
                'stack_trace': getattr(error, '__traceback__', None)
            })
        self.log(logging.ERROR, message, **extra)
    
    def spark_operation(
        self,
        message: str,
        operation_type: str,
        table_name: Optional[str] = None,
        **kwargs
    ) -> None:
        """Log a Spark operation with relevant context."""
        self.info(
            message,
            event_category='spark_operation',
            operation_type=operation_type,
            table_name=table_name,
            **kwargs
        )
    
    def delta_operation(
        self,
        message: str,
        operation_type: str,
        table_name: str,
        **kwargs
    ) -> None:
        """Log a Delta Lake operation with relevant context."""
        self.info(
            message,
            event_category='delta_operation',
            operation_type=operation_type,
            table_name=table_name,
            **kwargs
        )
    
    def performance_metric(
        self,
        message: str,
        duration_ms: float,
        **kwargs
    ) -> None:
        """Log a performance metric."""
        self.info(
            message,
            event_category='performance',
            duration_ms=duration_ms,
            **kwargs
        ) 