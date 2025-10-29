# Rails on Tap - Portainer Quick Reference

## 🚀 Quick Deployment Steps

### 1. Build & Push Image
```bash
./bin/deploy-to-registry
```
Or manually:
```bash
docker build -t yourusername/rails-on-tap:latest .
docker push yourusername/rails-on-tap:latest
```

### 2. Get Your Master Key
```bash
cat config/master.key
```

### 3. Deploy in Portainer
1. Go to Stacks → Add Stack
2. Name: `rails-on-tap`
3. Paste `docker-compose.production.yml`
4. Add environment variable: `RAILS_MASTER_KEY=your_key`
5. Click Deploy

### 4. Access Your App
```
http://your-server-ip:3000
```

---

## 📋 Files Created

- **`docker-compose.production.yml`** - Production stack configuration
- **`PORTAINER_DEPLOYMENT.md`** - Complete deployment guide
- **`.env.production.example`** - Environment variables template
- **`bin/deploy-to-registry`** - Build & push automation script

---

## 🔧 Common Commands

### Check Status
```bash
docker ps | grep rails-on-tap
```

### View Logs
```bash
docker logs rails-on-tap-backend
docker logs -f rails-on-tap-backend  # Follow logs
```

### Run Database Migrations
```bash
docker exec -it rails-on-tap-backend bash
cd /rails
./bin/rails db:migrate
```

### Restart Stack
In Portainer: Stacks → rails-on-tap → Stop/Start

### Update Deployment
1. Build & push new image
2. In Portainer: Stack → Update → Pull latest images

---

## 🔒 Security Checklist

- [ ] Never commit `.env.production` with real secrets
- [ ] Keep `config/master.key` secure
- [ ] Set up regular backups of `/rails/storage` volume
- [ ] Use HTTPS with reverse proxy (Traefik/Nginx)
- [ ] Restrict network access to necessary ports only
- [ ] Update base images regularly for security patches

---

## 🐛 Troubleshooting

### Container won't start
```bash
docker logs rails-on-tap-backend
# Check for missing RAILS_MASTER_KEY or database errors
```

### Database issues
```bash
docker exec -it rails-on-tap-backend bash
./bin/rails db:migrate RAILS_ENV=production
```

### Can't access app
- Check firewall: `sudo ufw allow 3000/tcp`
- Verify container is running: `docker ps`
- Check port binding: Should be `0.0.0.0:3000->80/tcp`

---

## 💾 Backup Commands

### Backup Everything
```bash
docker run --rm \
  -v rails-storage:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/rails-backup-$(date +%Y%m%d).tar.gz /data
```

### Restore Backup
```bash
docker run --rm \
  -v rails-storage:/data \
  -v $(pwd)/backup:/backup \
  alpine tar xzf /backup/rails-backup-YYYYMMDD.tar.gz -C /
```

---

## 📞 Support Resources

- Full Guide: `PORTAINER_DEPLOYMENT.md`
- Main README: `README.md`
- Dockerfile: `Dockerfile`
- Stack Config: `docker-compose.production.yml`

---

## 🎯 Production Checklist

Before going live:

- [ ] Master key configured in environment variables
- [ ] Database initialized (`db:migrate`, `db:seed`)
- [ ] Storage volumes created and mounted
- [ ] Redis connection working
- [ ] Logs accessible and monitored
- [ ] Backup strategy in place
- [ ] SSL/HTTPS configured (reverse proxy)
- [ ] Health checks passing
- [ ] Application accessible from network
- [ ] Firewall rules configured

---

**Need more help?** See `PORTAINER_DEPLOYMENT.md` for detailed instructions.
