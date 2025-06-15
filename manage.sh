#!/bin/bash

# Configuration
DOCKERFILE="Dockerfile.minimal"
COMPOSE_PROJECT="pentest-environment"

case "$1" in
    build)
        echo "Building Docker image using $DOCKERFILE..."
        docker-compose build --no-cache
        ;;
    build-minimal)
        echo "Building with Dockerfile.minimal..."
        docker-compose build --no-cache
        ;;
    up|start)
        echo "Starting pentest environment..."
        docker-compose up -d
        echo "Waiting for services to start..."
        sleep 15
        echo "Setting up Metasploit database..."
        # Use the script built into the container
        docker-compose exec pentest-server bash /home/pentester/scripts/setup-metasploit.sh || echo "Metasploit setup failed, you can run it manually later"
        echo ""
        echo "Environment is ready!"
        echo "Access the shell with: ./manage.sh shell"
        echo "Web interface available at: http://localhost"
        ;;
    down|stop)
        echo "Stopping pentest environment..."
        docker-compose down
        ;;
    shell)
        echo "Opening shell in pentest container..."
        docker-compose exec pentest-server /bin/bash
        ;;
    logs)
        if [ -n "$2" ]; then
            docker-compose logs -f "$2"
        else
            docker-compose logs -f pentest-server
        fi
        ;;
    status)
        docker-compose ps
        ;;
    clean)
        echo "Cleaning up everything..."
        docker-compose down -v
        docker system prune -f
        echo "Cleanup complete!"
        ;;
    restart)
        echo "Restarting services..."
        docker-compose restart
        ;;
    rebuild)
        echo "Rebuilding and restarting..."
        docker-compose down
        docker-compose build --no-cache
        docker-compose up -d
        ;;
    backup)
        echo "Creating backup..."
        mkdir -p backups
        BACKUP_NAME="metasploit-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
        docker run --rm \
            -v ${COMPOSE_PROJECT}_metasploit-data:/data \
            -v $(pwd)/backups:/backup \
            alpine tar czf /backup/$BACKUP_NAME -C /data .
        echo "Backup created: backups/$BACKUP_NAME"
        ;;
    setup-msf)
        echo "Setting up Metasploit database..."
        docker-compose exec pentest-server bash /home/pentester/scripts/setup-metasploit.sh
        ;;
    test-tools)
        echo "Testing installed tools..."
        docker-compose exec pentest-server bash -c "
            echo '=== Testing Tools ==='
            echo 'Nmap version:'
            nmap --version | head -2
            echo ''
            echo 'Nikto version:'
            nikto -Version 2>/dev/null || echo 'Nikto installed'
            echo ''
            echo 'Metasploit version:'
            msfconsole -v 2>/dev/null || echo 'Metasploit installed'
            echo ''
            echo 'Hydra version:'
            hydra -h | head -1 2>/dev/null || echo 'Hydra installed'
            echo ''
            echo 'SQLMap version:'
            sqlmap --version 2>/dev/null || echo 'SQLMap installed'
            echo ''
            echo 'Python packages:'
            python3 -c 'import requests, bs4, dns.resolver; print(\"Python packages OK\")'
        "
        ;;
    update)
        echo "Updating tools..."
        docker-compose exec pentest-server bash -c "
            echo 'Updating system packages...'
            apt-get update && apt-get upgrade -y
            echo 'Updating Metasploit...'
            msfupdate || echo 'Metasploit update failed'
            echo 'Update complete!'
        "
        ;;
    web)
        echo "Opening web interface..."
        if command -v xdg-open > /dev/null; then
            xdg-open http://localhost
        elif command -v open > /dev/null; then
            open http://localhost
        else
            echo "Web interface available at: http://localhost"
        fi
        ;;
    *)
        echo "Pentest Environment Manager"
        echo "Usage: $0 {command}"
        echo ""
        echo "Build Commands:"
        echo "  build         - Build Docker image"
        echo "  rebuild       - Clean build and restart"
        echo ""
        echo "Runtime Commands:"
        echo "  up/start      - Start the environment"
        echo "  down/stop     - Stop the environment"
        echo "  restart       - Restart services"
        echo "  shell         - Get a shell in the container"
        echo ""
        echo "Management Commands:"
        echo "  status        - Show container status"
        echo "  logs [service]- View container logs"
        echo "  setup-msf     - Setup Metasploit database"
        echo "  test-tools    - Test installed tools"
        echo "  update        - Update all tools"
        echo "  web           - Open web interface"
        echo ""
        echo "Maintenance Commands:"
        echo "  clean         - Remove all containers and volumes"
        echo "  backup        - Backup Metasploit data"
        echo ""
        exit 1
        ;;
esac
