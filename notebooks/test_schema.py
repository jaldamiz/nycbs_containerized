import os
import sys
import importlib

# Add notebooks directory to Python path
notebooks_dir = os.path.abspath("/home/aldamiz/notebooks")
if notebooks_dir not in sys.path:
    sys.path.append(notebooks_dir)

print("Current working directory:", os.getcwd())
print("Python path:", sys.path)
print("Notebooks directory exists:", os.path.exists(notebooks_dir))
print(
    "schema_manager.py exists:",
    os.path.exists(os.path.join(notebooks_dir, "schema_manager.py")),
)

# Force reload the module
import schema_manager

importlib.reload(schema_manager)

# Import and test SchemaManager
from schema_manager import SchemaManager

print("\nTesting SchemaManager...")
print(
    "SchemaManager methods:",
    [method for method in dir(SchemaManager) if not method.startswith("_")],
)

try:
    schema = SchemaManager.get_bronze_schema()
    print("\nSuccessfully got bronze schema")
    print(type(schema))
    print(schema)
except Exception as e:
    print("\nError getting bronze schema:")
    print(f"Error type: {type(e)}")
    print(f"Error message: {str(e)}")
    raise
