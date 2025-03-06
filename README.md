# NYC Bike Share Data Analysis

This project provides tools and analysis for NYC Bike Share data using PySpark, Delta Lake, and Streamlit.

## Features

- Data ingestion and processing with PySpark
- Data storage using Delta Lake format
- Interactive visualizations with Streamlit
- Jupyter notebooks for analysis
- Logging and monitoring with ELK stack

## Setup

1. Clone the repository
2. Install dependencies: `pip install -r requirements.txt`
3. Install the package in development mode: `pip install -e .`

## Project Structure

```
nycbs/
├── conf/                  # Configuration files
├── notebooks/            # Jupyter notebooks
├── src/                 # Source code
│   └── nycbs/          # Main package
├── data/               # Data directories
│   ├── landing/       # Raw data
│   ├── bronze/       # Cleaned data
│   ├── silver/      # Transformed data
│   └── gold/       # Analysis ready data
└── docs/           # Documentation
```

## Development

- Use `black` for code formatting
- Use `flake8` for linting
- Run tests with `pytest` 