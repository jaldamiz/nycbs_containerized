from logger import get_etl_logger, get_data_logger, get_analysis_logger, log_with_context
import logging
import time
from datetime import datetime
import random

def generate_test_logs(duration_seconds=60):
    """Generate test logs for a specified duration"""
    
    # Get our loggers
    etl_logger = get_etl_logger()
    data_logger = get_data_logger()
    analysis_logger = get_analysis_logger()
    
    print(f"Generating logs for {duration_seconds} seconds...")
    start_time = time.time()
    
    # Sample operations and their possible statuses
    operations = ['data_ingestion', 'data_transformation', 'data_validation', 'data_export']
    statuses = ['started', 'in_progress', 'completed', 'failed']
    
    batch_id = 1
    while time.time() - start_time < duration_seconds:
        # Simulate ETL logs
        log_with_context(
            etl_logger,
            logging.INFO,
            f"Processing batch {batch_id}",
            batch_id=batch_id,
            operation=random.choice(operations),
            status=random.choice(statuses),
            records_processed=random.randint(100, 1000)
        )
        
        # Simulate data quality logs
        if random.random() < 0.3:  # 30% chance of data quality issue
            log_with_context(
                data_logger,
                logging.WARNING,
                f"Data quality check failed for batch {batch_id}",
                batch_id=batch_id,
                null_count=random.randint(0, 50),
                duplicate_count=random.randint(0, 20)
            )
        
        # Simulate analysis logs
        if random.random() < 0.2:  # 20% chance of analysis error
            try:
                raise ValueError("Sample analysis error")
            except Exception as e:
                analysis_logger.error(
                    f"Analysis failed for batch {batch_id}",
                    exc_info=True
                )
        else:
            log_with_context(
                analysis_logger,
                logging.INFO,
                f"Analysis completed for batch {batch_id}",
                batch_id=batch_id,
                metrics={
                    'accuracy': round(random.uniform(0.8, 1.0), 2),
                    'processing_time': random.uniform(0.5, 2.0)
                }
            )
        
        batch_id += 1
        time.sleep(1)  # Wait 1 second between batches
    
    print("Log generation completed!")

if __name__ == "__main__":
    generate_test_logs() 