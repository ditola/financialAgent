# Database Project Structure

This project organizes SQL files for creating, populating, and querying a financial database with dummy data for testing purposes.

## Files

- `01_create_schema.sql`: Defines the database tables, relationships, indexes, and views.
- `02_insert_dummy_data.sql`: Populates tables with sample data to test functionality.
- `03_access_queries.sql`: Contains sample queries for accessing and analyzing data.
- `04_functions_triggers.sql`: (Optional) Contains any stored functions or triggers.

## Running the Project

Run each file in sequence to set up the database:

1. **Create Schema**: `psql -U <user> -d <database> -f sql/01_create_schema.sql`
2. **Insert Dummy Data**: `psql -U <user> -d <database> -f sql/02_insert_dummy_data.sql`
3. **Set Up Functions/Triggers**: `psql -U <user> -d <database> -f sql/04_functions_triggers.sql`
4. **Run Queries**: `psql -U <user> -d <database> -f sql/03_access_queries.sql`

Replace `<user>` and `<database>` with your specific PostgreSQL username and database name.
