#!/bin/bash
set -e

echo "Setting up Metasploit database..."

# Wait for PostgreSQL
for i in {1..30}; do
    if pg_isready -h postgres -p 5432 -U msf_user -d msf_database 2>/dev/null; then
        echo "PostgreSQL is ready!"
        break
    fi
    echo "Waiting for PostgreSQL... ($i/30)"
    sleep 2
done

# Initialize Metasploit database
echo "Initializing Metasploit database..."
msfdb init --connection-string="postgres://msf_user:msf_password@postgres:5432/msf_database" || true

# Create database config
mkdir -p ~/.msf4
cat > ~/.msf4/database.yml << DBEOF
production:
  adapter: postgresql
  database: msf_database
  username: msf_user
  password: msf_password
  host: postgres
  port: 5432
  pool: 5
  timeout: 5
DBEOF

echo "Metasploit setup complete!"
