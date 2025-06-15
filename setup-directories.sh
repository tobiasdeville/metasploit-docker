#!/bin/bash

echo "Setting up project directories..."

# Create all required directories
mkdir -p scripts
mkdir -p shared
mkdir -p wordlists
mkdir -p results
mkdir -p web-content
mkdir -p backups

# Create the setup script
cat > scripts/setup-metasploit.sh << 'EOF'
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
EOF

# Make script executable
chmod +x scripts/setup-metasploit.sh

# Create basic web content
cat > web-content/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Pentest Environment</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Pentest Environment Dashboard</h1>
        <p class="status">Environment is running!</p>
        <p>Access the shell with: <code>./manage.sh shell</code></p>
    </div>
</body>
</html>
EOF

echo "Directory setup complete!"
echo "You can now run: ./manage.sh build-minimal"
