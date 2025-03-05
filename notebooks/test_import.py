import os
import sys

# Add notebooks directory to Python path
notebooks_dir = os.path.abspath("/home/aldamiz/notebooks")
print(f"Notebooks directory: {notebooks_dir}")
print(f"Directory exists: {os.path.exists(notebooks_dir)}")
print(f"Directory contents: {os.listdir(notebooks_dir)}")
print(f"Current Python path: {sys.path}")

if notebooks_dir not in sys.path:
    sys.path.append(notebooks_dir)
    print(f"Added {notebooks_dir} to Python path")

print("\nTrying to import SchemaManager...")
try:
    from schema_manager import SchemaManager

    print("Successfully imported SchemaManager")

    print("\nTrying to get bronze schema...")
    schema = SchemaManager.get_bronze_schema()
    print(f"Successfully got bronze schema: {schema}")
except Exception as e:
    print(f"Error: {str(e)}")
    print(f"Error type: {type(e)}")
