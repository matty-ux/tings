#!/bin/bash

# Vend GB Server Startup Script
echo "🚀 Starting Vend GB Server..."

# Navigate to server directory
cd server

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Start the server
echo "🌟 Starting Express server..."
npm start
