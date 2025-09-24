#!/bin/bash

# Vend GB Server Deployment Script
# This script helps you deploy to various cloud platforms

echo "🚀 Vend GB Server Deployment Helper"
echo "=================================="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Please run this script from the server directory"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed"
    exit 1
fi

echo "✅ Node.js version: $(node --version)"
echo "✅ NPM version: $(npm --version)"
echo ""

# Test the server locally first
echo "🧪 Testing server locally..."
npm start &
SERVER_PID=$!
sleep 3

# Test health endpoint
if curl -s http://localhost:3001/health > /dev/null; then
    echo "✅ Server is running and healthy"
else
    echo "❌ Server health check failed"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

kill $SERVER_PID 2>/dev/null
echo ""

# Show deployment options
echo "🌐 Choose your deployment platform:"
echo ""
echo "1. Railway (Recommended - Free tier, easy setup)"
echo "2. Render (Free tier available)"
echo "3. Heroku (Paid plans only)"
echo "4. DigitalOcean App Platform"
echo "5. Docker deployment"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo ""
        echo "🚂 Railway Deployment Instructions:"
        echo "1. Go to https://railway.app"
        echo "2. Sign up with GitHub"
        echo "3. Click 'New Project' → 'Deploy from GitHub repo'"
        echo "4. Select your repository"
        echo "5. Railway will auto-detect your Node.js app"
        echo "6. Your app will be live at: https://your-app-name.railway.app"
        echo ""
        echo "📝 Don't forget to update your iOS app's baseURL!"
        ;;
    2)
        echo ""
        echo "🎨 Render Deployment Instructions:"
        echo "1. Go to https://render.com"
        echo "2. Sign up and connect GitHub"
        echo "3. Click 'New' → 'Web Service'"
        echo "4. Connect your repository"
        echo "5. Build Command: npm install"
        echo "6. Start Command: npm start"
        echo "7. Your app will be live at: https://your-app-name.onrender.com"
        ;;
    3)
        echo ""
        echo "💜 Heroku Deployment Instructions:"
        echo "1. Install Heroku CLI: npm install -g heroku"
        echo "2. Login: heroku login"
        echo "3. Create app: heroku create your-app-name"
        echo "4. Deploy: git push heroku main"
        echo "5. Your app will be live at: https://your-app-name.herokuapp.com"
        ;;
    4)
        echo ""
        echo "🌊 DigitalOcean App Platform Instructions:"
        echo "1. Go to https://cloud.digitalocean.com/apps"
        echo "2. Click 'Create App'"
        echo "3. Connect your GitHub repository"
        echo "4. Configure as Web Service"
        echo "5. Build Command: npm install"
        echo "6. Run Command: npm start"
        ;;
    5)
        echo ""
        echo "🐳 Docker Deployment:"
        echo "1. Build image: docker build -t vend-gb-server ."
        echo "2. Run container: docker run -p 3001:3001 vend-gb-server"
        echo "3. For production, deploy to:"
        echo "   - Google Cloud Run"
        echo "   - AWS ECS/Fargate"
        echo "   - Azure Container Instances"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🔧 Post-deployment checklist:"
echo "1. Test your deployed API endpoints"
echo "2. Update iOS app's baseURL to your deployed URL"
echo "3. Consider adding authentication for admin routes"
echo "4. Set up monitoring and error tracking"
echo "5. Consider migrating from JSON files to a database"
echo ""
echo "📚 For detailed instructions, see DEPLOYMENT.md"
echo "🎉 Happy deploying!"
