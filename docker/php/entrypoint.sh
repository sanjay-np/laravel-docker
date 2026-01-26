#!/bin/bash
set -e

# Generate supervisor config for each project found in /var/www
echo "Scanning for Laravel projects..."

# Clear old worker configs
rm -f /etc/supervisor/conf.d/*-worker.conf

for project in /var/www/*; do
    if [ -d "$project" ] && [ -f "$project/artisan" ]; then
        project_name=$(basename "$project")
        echo "Found project: $project_name"
        
        # Ensure log directory exists
        if [ ! -d "$project/storage/logs" ]; then
            mkdir -p "$project/storage/logs"
            chown -R laravel:laravel "$project/storage"
        fi

        cat <<EOF > /etc/supervisor/conf.d/${project_name}-worker.conf
[program:${project_name}-worker]
process_name=%(program_name)s_%(process_num)02d
command=php $project/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=laravel
numprocs=2
redirect_stderr=true
stdout_logfile=$project/storage/logs/worker.log
stopwaitsecs=3600
EOF
    fi
done

# Start supervisor
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
