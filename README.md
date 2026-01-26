# Laravel Docker Environment

A lightweight, Docker-based development environment for Laravel, featuring Nginx, PHP 8.4, MySQL 8.4, and phpMyAdmin.

## Services

| Service | Container Name | Description | Ports |
| :--- | :--- | :--- | :--- |
| **Nginx** | `laravel_nginx` | Web server | `80:80` |
| **App** | `laravel_app` | PHP 8.4, Supervisor, Cron, Laravel Installer | `5173:5173` |
| **Redis** | `laravel_redis` | Key-value store (Cache/Queue) | `6379:6379` |
| **Database** | `laravel_db` | MySQL 8.4 | `3306:3306` |
| **phpMyAdmin** | `laravel_phpmyadmin` | Database management UI | `8081:80` |

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd laravel-docker
   ```

2. **Configure Environment Variables**
   Create or update the `.env` file in the root directory:
   ```bash
   # .env
   DOCKER_PHP_VERSION=8.4

   # Database Configuration
   DB_HOST=db
   DB_PORT=3306
   DB_DATABASE=laravel
   DB_USERNAME=laravel
   DB_PASSWORD=secret
   ```

3. **Start the containers**
   ```bash
   docker compose up -d --build
   ```

## Setting up Laravel

The `src/` directory is mapped to `/var/www` inside the container.

### Option A: New Laravel Project
If `src/` is empty, you can install a fresh Laravel application:
```bash
# Delete the placeholder file if exists
rm src/index.php

# Install Laravel
docker compose exec app composer create-project laravel/laravel .
```

### Option B: Existing Project
Move your existing Laravel project files into the `src/` directory.

### Configure Laravel's Database Connection
Update `src/.env` with:
```env
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
```

## Usage

### Accessing the Application

| Service | URL | Description |
| :--- | :--- | :--- |
| **Web App** | [http://localhost:8080](http://localhost:8080) | Main Laravel application |
| **phpMyAdmin** | [http://localhost:8081](http://localhost:8081) | Database management |
| **Vite HMR** | [http://localhost:5173](http://localhost:5173) | Hot Module Replacement |
| **MySQL** | `localhost:3306` | Database (from host machine) |

### phpMyAdmin Login

| Field | Value |
| :--- | :--- |
| Server | `db` (pre-filled) |
| Username | `root` or `laravel` |
| Password | `secret` |

> **Note:** phpMyAdmin supports connecting to any MySQL server. Set `PMA_ARBITRARY=1` to enable this feature.

### Helper Scripts

Helper scripts are project-aware. If the first argument is a directory in `src/`, the command will run inside that folder.

**Create Multiple Projects**
```bash
./laravel new app1
./laravel new app2
```

**Run Artisan in Specific Project**
```bash
./artisan app1 migrate
./artisan app2 make:controller UserOps
```

**Run Composer in Specific Project**
```bash
./composer app1 install
./composer app2 require laravel/breeze
```

### Multiple Databases

To create multiple databases on startup:

1.  Open `.env` in the project root.
2.  Add your database names to `MYSQL_ADDITIONAL_DATABASES`:
    ```env
    MYSQL_ADDITIONAL_DATABASES=app2_db,app3_db
    ```
3.  Restart Docker containers:
    ```bash
    docker compose down && docker compose up -d
    ```

### Accessing Multiple Projects

Since we are now using port 80, you no longer need to specify `:8080`.

| Project Folder | URL |
| :--- | :--- |
| `src/app1` | [http://app1.localhost](http://app1.localhost) |
| `src/app2` | [http://app2.localhost](http://app2.localhost) |
| `src/` (root) | [http://localhost](http://localhost) |

### Server Features

#### 1. Background Jobs (Queue Workers)
Supervisor is installed and running inside the `app` container. It **automatically detects** Laravel projects in subdirectories and creates a worker for each one.

- **Auto-Discovery**: On container startup, the entrypoint script scans `src/` for projects containing an `artisan` file.
- **Worker Config**: It generates a Supervisor config file for each found project (e.g., `app1-worker.conf`).
- **Logs**: Worker logs are stored in `src/<project-name>/storage/logs/worker.log`.
- **Applying Changes**: If you **add or remove** a project, **you must restart the container** for the configuration to update.
  - **Adding**: Registers the new worker.
  - **Removing**: Stops and creates a clean slate, removing the worker for the deleted project.
  ```bash
  docker compose restart app
  # or
  docker compose down && docker compose up -d
  ```

#### 2. Caching & Sessions (Redis)
Redis is available at host `redis` (inside Docker) or `localhost:6379` (outside).
To use it in Laravel, update your project's `.env`:
```env
CACHE_STORE=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
REDIS_HOST=redis
```

#### 3. Task Scheduling (Cron)
Cron is running inside the container and is pre-configured to run the Laravel Scheduler every minute.

### Traditional Commands

Alternatively, you can run commands directly using `docker compose`:

**Composer**
```bash
docker compose exec app composer install
```

**Artisan**
```bash
docker compose exec app php artisan migrate
docker compose exec app php artisan optimize:clear
```

**Bun / Bunx / NPM**
```bash
docker compose exec app bun install
docker compose exec app bun run dev
docker compose exec app bunx <package>  # Run packages without installing
```

**Shell Access**
```bash
docker compose exec app bash
```

## Connecting to External Database

To connect to a MySQL database on another machine (e.g., another PC on your network):

1. **Update `src/.env`**:
   ```env
   DB_HOST=192.168.1.xxx    # IP of the other PC
   DB_PORT=3306
   DB_DATABASE=your_database
   DB_USERNAME=your_username
   DB_PASSWORD=your_password
   ```

2. **Ensure the external MySQL allows remote connections**:
   - Edit MySQL config: `bind-address = 0.0.0.0`
   - Create a user with remote access:
     ```sql
     CREATE USER 'username'@'%' IDENTIFIED BY 'password';
     GRANT ALL PRIVILEGES ON database.* TO 'username'@'%';
     FLUSH PRIVILEGES;
     ```
   - Open firewall port 3306

3. **Update phpMyAdmin** (optional):
   In `docker-compose.yml`, change `PMA_HOST`:
   ```yaml
   environment:
     PMA_HOST: 192.168.1.xxx
   ```

## Configuration

### PHP Configuration
The environment includes custom PHP configuration with the following limits:
- **Upload Max Filesize**: 50M
- **Post Max Size**: 50M  
- **Memory Limit**: 256M
- **Max Execution Time**: 300 seconds

### Nginx Configuration
- **Maximum Upload Size**: 50M
- **Document Root**: `/var/www/public`

### phpMyAdmin Configuration
- **Upload Limit**: 1G (for importing large SQL files)
- **Arbitrary Server Connection**: Enabled

## Vite Configuration (for Docker)

If using Vite for frontend development, update `vite.config.js`:
```javascript
server: {
    host: "0.0.0.0",        // Listen on all interfaces
    hmr: {
        host: "localhost",  // Browser connects via localhost
    },
},
```

## Project Structure

```
laravel-docker/
├── docker/
│   ├── nginx/
│   │   └── default.conf     # Nginx configuration
│   └── php/
│       └── Dockerfile       # PHP 8.4 image build
├── src/                     # Laravel application (mapped to /var/www)
├── docker-compose.yml       # Service definitions
├── .env                     # Docker environment variables
├── artisan                  # Helper script for artisan commands
├── composer                 # Helper script for composer commands
├── laravel                  # Helper script for laravel installer commands
└── README.md
```

## Troubleshooting

### Port Conflicts
If you get "port already in use" errors:
```bash
# Check what's using a port
lsof -i :3306

# Use a different port in docker-compose.yml
ports:
  - "3310:3306"  # Use 3310 instead
```

### "Page Expired" Error (CSRF Issues)
If using an external database and getting CSRF errors:
```env
# In src/.env, use file-based sessions instead of database
SESSION_DRIVER=file
CACHE_STORE=file
```

### Clear All Caches
```bash
docker compose exec app php artisan optimize:clear
```

## License

This project is open-sourced software.
