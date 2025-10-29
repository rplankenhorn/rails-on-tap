# Deploying Rails on Tap to Portainer

This guide walks you through deploying Rails on Tap to your Portainer instance.

## Prerequisites

1. **Portainer installed** on your network
2. **Docker registry access** (Docker Hub account or private registry)
3. **Rails Master Key** from `config/master.key`

## Deployment Methods

You have two options for deploying to Portainer:

### Option A: Using Portainer Stacks (Recommended)

This method uses Portainer's built-in stack management.

### Option B: Manual Container Creation

Create containers individually through Portainer UI.

---

## Option A: Portainer Stack Deployment (Recommended)

### Step 1: Build and Push Docker Image

First, build your Docker image and push it to a registry that Portainer can access.

#### Using Docker Hub:

```bash
# Login to Docker Hub
docker login

# Build the image
docker build -t yourusername/rails-on-tap:latest .

# Push to Docker Hub
docker push yourusername/rails-on-tap:latest
```

#### Using a Private Registry:

```bash
# Build the image
docker build -t your-registry.local:5000/rails-on-tap:latest .

# Push to your private registry
docker push your-registry.local:5000/rails-on-tap:latest
```

### Step 2: Prepare Your Master Key

1. Copy your Rails master key:
   ```bash
   cat config/master.key
   ```
2. Keep this value secure - you'll need it for the environment variables.

### Step 3: Update docker-compose.production.yml

Update the image name in `docker-compose.production.yml`:

```yaml
services:
  rails:
    image: yourusername/rails-on-tap:latest  # Change this to your image
    # ... rest of config
```

### Step 4: Deploy Stack in Portainer

1. **Login to Portainer** (e.g., http://your-portainer-ip:9000)

2. **Navigate to Stacks**:
   - Click on "Stacks" in the left sidebar
   - Click "+ Add stack"

3. **Configure the Stack**:
   - **Name**: `rails-on-tap`
   - **Build method**: Select "Web editor"

4. **Paste the docker-compose.production.yml content**:
   - Copy the entire contents of `docker-compose.production.yml`
   - Paste it into the web editor

5. **Add Environment Variables**:
   Scroll down to "Environment variables" and add:
   
   ```
   RAILS_MASTER_KEY=your_actual_master_key_here
   ```
   
   Optional variables:
   ```
   RAILS_ALLOWED_HOSTS=192.168.1.100,your-domain.com
   ```

6. **Deploy the Stack**:
   - Click "Deploy the stack"
   - Wait for containers to start

### Step 5: Verify Deployment

1. **Check Container Status**:
   - Go to "Containers" in Portainer
   - Verify both `rails-on-tap-backend` and `rails-on-tap-redis` are running

2. **Check Logs**:
   - Click on `rails-on-tap-backend` container
   - Go to "Logs" tab
   - Look for "Listening on http://0.0.0.0:80"

3. **Access the Application**:
   - Open browser to `http://your-server-ip:3000`
   - You should see the Rails on Tap dashboard

### Step 6: Initialize Database (First Time Only)

If this is your first deployment, you may need to initialize the database:

1. **Open Container Console**:
   - In Portainer, click on `rails-on-tap-backend` container
   - Click "Console" tab
   - Select "/bin/bash" and click "Connect"

2. **Run Database Commands**:
   ```bash
   cd /rails
   ./bin/rails db:migrate
   ./bin/rails db:seed
   ```

---

## Option B: Manual Container Creation

If you prefer not to use stacks, you can create containers manually:

### 1. Create Network

```bash
docker network create rails-on-tap
```

### 2. Start Redis

```bash
docker run -d \
  --name rails-on-tap-redis \
  --network rails-on-tap \
  --restart unless-stopped \
  -v redis-data:/data \
  redis:7-alpine
```

### 3. Start Rails App

```bash
docker run -d \
  --name rails-on-tap-backend \
  --network rails-on-tap \
  --restart unless-stopped \
  -p 3000:80 \
  -e RAILS_ENV=production \
  -e RAILS_MASTER_KEY=your_master_key_here \
  -e REDIS_URL=redis://rails-on-tap-redis:6379/0 \
  -v rails-storage:/rails/storage \
  -v rails-logs:/rails/log \
  yourusername/rails-on-tap:latest
```

---

## Updating Your Deployment

When you make changes and want to update:

### Using Stacks:

1. Build and push new image:
   ```bash
   docker build -t yourusername/rails-on-tap:latest .
   docker push yourusername/rails-on-tap:latest
   ```

2. In Portainer:
   - Go to your stack
   - Click "Update the stack"
   - Enable "Pull latest image versions"
   - Click "Update"

### Manual Method:

```bash
# Pull latest image
docker pull yourusername/rails-on-tap:latest

# Stop and remove old container
docker stop rails-on-tap-backend
docker rm rails-on-tap-backend

# Start new container (use same docker run command as before)
```

---

## Troubleshooting

### Container Won't Start

1. **Check logs**:
   ```bash
   docker logs rails-on-tap-backend
   ```

2. **Common issues**:
   - Missing `RAILS_MASTER_KEY` environment variable
   - Database migration needed
   - Port 3000 already in use

### Database Issues

If you get database errors:

```bash
# Access container console
docker exec -it rails-on-tap-backend bash

# Run migrations
cd /rails
./bin/rails db:migrate RAILS_ENV=production
```

### Permission Issues

If you get file permission errors:

```bash
# Fix ownership
docker exec -it rails-on-tap-backend bash
chown -R rails:rails /rails/storage /rails/log
```

### Can't Access Application

1. **Check container is running**:
   ```bash
   docker ps | grep rails-on-tap
   ```

2. **Check port mapping**:
   - Ensure port 3000 on host maps to port 80 in container
   - Try accessing: `http://your-server-ip:3000`

3. **Check firewall**:
   ```bash
   # On the Docker host
   sudo ufw allow 3000/tcp
   ```

### Redis Connection Issues

Check Redis is accessible:

```bash
docker exec -it rails-on-tap-backend bash
redis-cli -h rails-on-tap-redis ping
# Should return: PONG
```

---

## Backup and Restore

### Backup

```bash
# Backup SQLite databases
docker run --rm \
  -v rails-storage:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/rails-storage-$(date +%Y%m%d).tar.gz /data

# Backup uploaded files
docker run --rm \
  -v rails-public:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/rails-public-$(date +%Y%m%d).tar.gz /data
```

### Restore

```bash
# Restore storage
docker run --rm \
  -v rails-storage:/data \
  -v $(pwd)/backup:/backup \
  alpine tar xzf /backup/rails-storage-YYYYMMDD.tar.gz -C /
```

---

## Advanced Configuration

### Using PostgreSQL Instead of SQLite

For better performance and scalability, consider PostgreSQL:

1. Add to `docker-compose.production.yml`:
   ```yaml
   postgres:
     image: postgres:15-alpine
     environment:
       POSTGRES_DB: rails_on_tap_production
       POSTGRES_USER: rails
       POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
     volumes:
       - postgres-data:/var/lib/postgresql/data
     networks:
       - rails-on-tap
   ```

2. Update Rails service:
   ```yaml
   rails:
     environment:
       DATABASE_URL: postgresql://rails:${POSTGRES_PASSWORD}@postgres:5432/rails_on_tap_production
   ```

### Using Reverse Proxy (Traefik/Nginx)

Add labels for automatic reverse proxy configuration:

```yaml
rails:
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.rails-on-tap.rule=Host(`rails.yourdomain.com`)"
    - "traefik.http.services.rails-on-tap.loadbalancer.server.port=80"
```

### SSL/HTTPS

For SSL, use a reverse proxy like Traefik or Nginx Proxy Manager in front of the Rails app.

---

## Security Recommendations

1. **Never commit** `.env.production` with real secrets
2. **Use Docker secrets** for sensitive data in Portainer
3. **Set up regular backups** of the storage volume
4. **Keep images updated** - rebuild monthly for security patches
5. **Use a reverse proxy** with SSL for production
6. **Restrict network access** to only necessary ports
7. **Monitor logs** for suspicious activity

---

## Support

For issues specific to:
- **Rails app**: Check the main [README.md](../README.md)
- **Docker**: See [Dockerfile](../Dockerfile)
- **Portainer**: Visit [Portainer Documentation](https://docs.portainer.io/)
