#!/bin/bash
set -e

echo "Setting up Metasploit database..."

# Wait for PostgreSQL
echo "Waiting for PostgreSQL to be ready..."
for i in {1..60}; do
    if pg_isready -h postgres -p 5432 -U msf_user -d msf_database 2>/dev/null; then
        echo "PostgreSQL is ready!"
        break
    fi
    echo "Waiting for PostgreSQL... ($i/60)"
    sleep 2
done

# Test database connection
echo "Testing database connection..."
export PGPASSWORD=msf_password
if psql -h postgres -U msf_user -d msf_database -c "SELECT 1;" > /dev/null 2>&1; then
    echo "Database connection successful!"
else
    echo "Database connection failed!"
    exit 1
fi

# Create database config
echo "Creating database configuration..."
mkdir -p ~/.msf4
cat > ~/.msf4/database.yml << 'EOF'
production:
  adapter: postgresql
  database: msf_database
  username: msf_user
  password: msf_password
  host: postgres
  port: 5432
  pool: 5
  timeout: 5
EOF

chmod 600 ~/.msf4/database.yml

echo "Database configuration created successfully!"
echo "You can now use Metasploit with: msfconsole"
echo "Check database status with: msfconsole -q -x 'db_status; exit'"
