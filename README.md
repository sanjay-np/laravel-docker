# Laravel Docker Environment

A lightweight, Docker-based development environment for Laravel, featuring Nginx, PHP 8.4, and MySQL 8.4.

## Services

| Service | Container Name | Description | Ports |
| :--- | :--- | :--- | :--- |
| **Nginx** | `laravel_nginx` | Web server | `8080:80` |
| **App** | `laravel_app` | PHP 8.4 FPM, Composer, Bun, Bunx | `5173:5173` (Vite) |
| **Database** | `laravel_db` | MySQL 8.4 | - |

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd laravel-dockear
   ```

2. **Configure Environment Variables**
   Create or update the `.env` file in the root directory to define your database credentials:
   ```bash
   # .env
   DOCKER_PHP_VERSION=8.4
   DB_DATABASE=laravel
   DB_PASSWORD=secret
   ```

3. **Start the containers**
   ```bash
   docker compose up -d--build
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

## Usage

### Accessing the Application
- **Web**: [http://localhost:8080](http://localhost:8080)
- **Vite (HMR)**: [http://localhost:5173](http://localhost:5173)

### Common Commands
Run commands inside the `app` container:

**Composer**
```bash
docker compose exec app composer install
```

**Artisan**
```bash
docker compose exec app php artisan migrate
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

## Project Structure

- `docker/`: Docker configuration files (PHP, Nginx, custom PHP ini).
- `src/`: Your Laravel application code (mapped to `/var/www`).
- `docker-compose.yml`: Service definitions.
- `.env`: Environment variables for database credentials and PHP version.
