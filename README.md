# Laravel Docker Environment

A lightweight, Docker-based development environment for Laravel, featuring Nginx, PHP 8.4, MySQL 8.4, and phpMyAdmin.

## Services

| Service | Container Name | Description | Ports |
| :--- | :--- | :--- | :--- |
| **Nginx** | `laravel_nginx` | Web server | `8080:80` |
| **App** | `laravel_app` | PHP 8.4 FPM, Composer, Laravel Installer, Bun, Bunx | `5173:5173` (Vite) |
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

For convenience, helper scripts are provided in the project root to run commands inside the container without typing `docker compose exec app ...` every time.

**Laravel Installer**
```bash
./laravel new my-app
```

**Artisan**
```bash
./artisan migrate
./artisan make:controller MyController
```

**Composer**
```bash
./composer install
./composer require laravel/breeze
```

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
