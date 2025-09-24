# Cloud Deployment Guide for Vend GB Server

This guide covers multiple deployment options for your Express.js server.

## 🚀 Quick Deployment Options

### 1. Railway (Recommended - Easiest)

**Pros:** Simple setup, automatic deployments, persistent storage, free tier
**Best for:** Quick deployment with minimal configuration

#### Steps:
1. Go to [Railway.app](https://railway.app)
2. Sign up with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repository
5. Railway will automatically detect your Node.js app
6. Add environment variables if needed:
   - `NODE_ENV=production`
   - `PORT=3001` (optional, Railway sets this automatically)
7. Deploy!

**Your app will be live at:** `https://your-app-name.railway.app`

---

### 2. Render (Free Tier Available)

**Pros:** Free tier, easy GitHub integration, automatic SSL
**Best for:** Simple deployment with good free options

#### Steps:
1. Go to [Render.com](https://render.com)
2. Sign up and connect your GitHub
3. Click "New" → "Web Service"
4. Connect your repository
5. Configure:
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Environment:** `Node`
6. Add environment variables:
   - `NODE_ENV=production`
7. Click "Create Web Service"

**Your app will be live at:** `https://your-app-name.onrender.com`

---

### 3. Heroku (Classic Choice)

**Pros:** Mature platform, extensive documentation
**Cons:** No free tier anymore (paid plans start at $5/month)

#### Steps:
1. Install Heroku CLI: `npm install -g heroku`
2. Login: `heroku login`
3. Create app: `heroku create your-app-name`
4. Deploy: `git push heroku main`
5. Set environment variables:
   ```bash
   heroku config:set NODE_ENV=production
   ```

**Your app will be live at:** `https://your-app-name.herokuapp.com`

---

### 4. DigitalOcean App Platform

**Pros:** Good performance, reasonable pricing, easy scaling
**Best for:** Production applications with growth potential

#### Steps:
1. Go to [DigitalOcean App Platform](https://cloud.digitalocean.com/apps)
2. Click "Create App"
3. Connect your GitHub repository
4. Configure:
   - **Source:** Your repository
   - **Type:** Web Service
   - **Build Command:** `npm install`
   - **Run Command:** `npm start`
5. Add environment variables
6. Deploy!

---

## 🐳 Docker Deployment

If you prefer containerized deployment:

### Local Docker Testing
```bash
cd server
docker build -t vend-gb-server .
docker run -p 3001:3001 vend-gb-server
```

### Docker Compose (for local development)
```bash
docker-compose up -d
```

### Cloud Docker Deployment Options
- **Google Cloud Run**
- **AWS ECS/Fargate**
- **Azure Container Instances**

---

## ⚙️ Environment Configuration

Create a `.env` file (or set in your cloud platform):

```env
NODE_ENV=production
PORT=3001
```

---

## 📊 Database Considerations

**Current Setup:** File-based storage (JSON files)
- ✅ Works for development and small apps
- ❌ Not suitable for production with multiple instances
- ❌ Data can be lost if container restarts

**Recommended Production Changes:**
1. **PostgreSQL** (via Railway, Render, or external service)
2. **MongoDB Atlas** (cloud-hosted)
3. **Supabase** (PostgreSQL with real-time features)

---

## 🔒 Security Recommendations

1. **Add Authentication:** Your admin routes are currently open
2. **Rate Limiting:** Add express-rate-limit
3. **CORS Configuration:** Restrict to your domain
4. **Environment Variables:** Never commit secrets
5. **HTTPS:** Most platforms provide this automatically

---

## 📱 Mobile App Integration

After deployment, update your iOS app's `ProductService.swift`:

```swift
// Replace localhost with your deployed URL
private let baseURL = "https://your-app-name.railway.app"
```

---

## 🚨 Troubleshooting

### Common Issues:

1. **Port Configuration**
   - Ensure your app uses `process.env.PORT || 3001`
   - Most platforms set PORT automatically

2. **File Storage Issues**
   - JSON files may not persist on some platforms
   - Consider database migration for production

3. **Build Failures**
   - Check Node.js version compatibility
   - Ensure all dependencies are in package.json

4. **CORS Issues**
   - Update CORS settings for your domain
   - Test from your mobile app

### Getting Help:
- Check platform-specific logs
- Use `console.log()` for debugging
- Test locally with same environment variables

---

## 🎯 Recommended Next Steps

1. **Start with Railway** - easiest option
2. **Test deployment** with your mobile app
3. **Add authentication** for admin routes
4. **Migrate to database** for production
5. **Set up monitoring** and error tracking

---

## 📞 Support

If you encounter issues:
1. Check the platform's documentation
2. Review server logs
3. Test locally first
4. Consider the database migration for production use
