# Laravel Docker Environment

A robust, lightweight Docker-based development environment for Laravel on Linux.  
Includes **Nginx**, **PHP 8.4** (via FPM), **MySQL 8.4**, **Redis**, and **phpMyAdmin**.

---

## ⚡ Quick Start

### 1. Setup
Clone the repo and start the services.

```bash
# Clone
git clone <repository-url>
cd laravel-docker

# Configure Base Environment
cp .env.example .env 2>/dev/null || : # Ensure .env exists

# Start Containers
docker compose up -d --build
```

### 2. Create a Laravel Project
The `src/` directory is mapped to the container's `/var/www`. You can install a new project directly or move an existing one.

**Option A: New Project**
```bash
bin/laravel new my-app
```
_This creates a new Laravel app in `src/my-app`._

**Option B: Existing Project**
Move your project folder to `src/my-app`.

### 3. Access the Application

| Project Location | URL | Notes |
| :--- | :--- | :--- |
| `src/app1` | [http://app1.localhost](http://app1.localhost) | Access via subdomain |
| `src/` (root) | [http://localhost](http://localhost) | Access via root domain |

---

## 🛠 Helper Scripts

We provide wrapper scripts so you don't have to type `docker compose exec ...` every time.
These scripts are **context-aware**: if you point them to a specific project folder, they run inside that folder.

| Command | Usage Example | Description |
| :--- | :--- | :--- |
| `bin/artisan` | `bin/artisan app1 migrate` | Run Artisan commands |
| `bin/composer` | `bin/composer app1 require laravel/breeze` | Run Composer commands |
| `bin/bun` | `bin/bun app1 run dev` | Run Bun/NPM commands |
| `bin/laravel` | `bin/laravel new app2` | Laravel Installer |

---

## � Command Examples

Here are some common tasks you might need to perform.

### Artisan
Run any artisan command inside a project.

```bash
# General
bin/artisan app1 about
bin/artisan app1 list

# Migration
bin/artisan app1 migrate
bin/artisan app1 migrate:fresh --seed

# Make Commands
bin/artisan app1 make:controller UserController
bin/artisan app1 make:model Product -m
bin/artisan app1 make:test UserTest

# Cache Clearing
bin/artisan app1 optimize:clear
```

### Composer
Manage PHP dependencies.

```bash
# Install Dependencies
bin/composer app1 install

# Require a Package
bin/composer app1 require laravel/breeze --dev
bin/composer app1 require spatie/laravel-permission

# Autoload
bin/composer app1 dump-autoload
```

### Bun / Frontend
Manage frontend assets and run development servers.

```bash
# Install Node Dependencies
bin/bun app1 install

# Start Dev Server (Vite)
bin/bun app1 run dev

# Build for Production
bin/bun app1 run build

# Run specific command (e.g. running jest)
bin/bun app1 run test
```

### Testing
Run your test suite.
```bash
bin/artisan app1 test
```

---

## �📦 Services & Ports

| Service | Container Name | Description | Host Port | Internal Port |
| :--- | :--- | :--- | :--- | :--- |
| **Nginx** | `laravel_nginx` | Web Server | `80` | `80` |
| **MySQL** | `laravel_db` | Database | `3306` | `3306` |
| **Redis** | `laravel_redis` | Cache / Queue | `6379` | `6379` |
| **phpMyAdmin**| `laravel_phpmyadmin` | DB GUI | `8081` | `80` |
| **Vite** | `laravel_app` | Frontend Dev | `5173-5178`| `5173-5178` |

> **Note**: Vite ports (5173-5178) are open to allow multiple projects to run `bun run dev` simultaneously.

---

## ⚙️ Configuration

### Database Connection (Laravel)
Configure your Laravel project's `.env` file to connect to the internal Docker services.

```ini
DB_CONNECTION=mysql
DB_HOST=db             # Service name in docker-compose
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

CACHE_STORE=redis
REDIS_HOST=redis       # Service name in docker-compose
```

### Multiple Databases
To create extra databases on container startup, add them to the root `.env`:
```ini
MYSQL_ADDITIONAL_DATABASES=app1_db,app2_db
```
_Then restart the containers: `docker compose down && docker compose up -d`_

### Queue Workers (Supervisor)
Supervisor runs inside the container and **automatically detects** Laravel projects in `src/`.
- It scans `src/` for folders containing `artisan`.
- Automatically creates workers (`php artisan queue:work`).
- Logs are located at `src/<project>/storage/logs/worker.log`.

**To register new workers after adding a project:**
```bash
docker compose restart app
```

### Vite Configuration
Update `vite.config.js` in your Laravel project to work with Docker.

```javascript
export default defineConfig({
    server: {
        host: '0.0.0.0',
        hmr: {
            host: 'localhost',
        },
    },
    // ...
});
```

---

## 📂 Project Structure

```
laravel-docker/
├── .env                     # Docker Environment Variables
├── docker-compose.yml       # Service Config
├── docker/                  # Dockerfiles & Configs
│   ├── nginx/               # Nginx Sites
│   └── php/                 # PHP, Supervisor, Cron
├── src/                     # YOUR PROJECTS GO HERE (Mapped to /var/www)
│   ├── app1/
│   └── app2/
├── bin/                     # Helper Scripts
│   ├── artisan
│   ├── bun
│   ├── composer
│   └── laravel
```

---

## ❓ Troubleshooting

**Port Conflicts**
If ports 80 or 3306 are in use, modify `docker-compose.yml` or stop local services (`sudo service apache2 stop`, `sudo service mysql stop`).

**Permission Issues**
If you cannot write to directories, ensure permissions are set correctly:
```bash
sudo chown -R $USER:$USER src/
```

**Connecting to External DB**
Set `DB_HOST` in your Laravel `.env` to your host machine's IP (e.g., `192.168.1.50`) and ensure your external MySQL binds to `0.0.0.0`.
