#!/bin/bash
# Connect Four AI - Setup Script for Mac/Linux
# This script sets up the project for local development

echo "🚀 Setting up Connect Four AI..."
echo ""

# Check Node.js
echo "📦 Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi
NODE_VERSION=$(node --version)
echo "✅ Node.js version: $NODE_VERSION"

# Check npm
echo "📦 Checking npm..."
NPM_VERSION=$(npm --version)
echo "✅ npm version: $NPM_VERSION"
echo ""

# Install root dependencies
echo "📦 Installing root dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "❌ Failed to install root dependencies"
    exit 1
fi
echo "✅ Root dependencies installed"
echo ""

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
cd frontend
npm install
if [ $? -ne 0 ]; then
    echo "❌ Failed to install frontend dependencies"
    cd ..
    exit 1
fi
echo "✅ Frontend dependencies installed"
cd ..
echo ""

# Install backend dependencies
echo "📦 Installing backend dependencies..."
cd backend
npm install
if [ $? -ne 0 ]; then
    echo "❌ Failed to install backend dependencies"
    cd ..
    exit 1
fi
echo "✅ Backend dependencies installed"
cd ..
echo ""

# Create environment files
echo "📝 Creating environment files..."

# Frontend .env.local
if [ ! -f "frontend/.env.local" ]; then
    if [ -f "frontend/.env.example" ]; then
        cp frontend/.env.example frontend/.env.local
        echo "✅ Created frontend/.env.local from .env.example"
    else
        cat > frontend/.env.local << EOF
REACT_APP_API_URL=http://localhost:3000
REACT_APP_WS_URL=ws://localhost:3000
REACT_APP_ML_SERVICE_URL=http://localhost:8000
REACT_APP_ENVIRONMENT=development
REACT_APP_VERSION=1.0.0
REACT_APP_ANALYTICS_ENABLED=false
EOF
        echo "✅ Created frontend/.env.local"
    fi
else
    echo "ℹ️  frontend/.env.local already exists, skipping"
fi

# Backend .env
if [ ! -f "backend/.env" ]; then
    if [ -f "backend/.env.example" ]; then
        cp backend/.env.example backend/.env
        echo "✅ Created backend/.env from .env.example"
    else
        cat > backend/.env << EOF
NODE_ENV=development
PORT=3000
CORS_ORIGIN=http://localhost:3001
EOF
        echo "✅ Created backend/.env"
    fi
else
    echo "ℹ️  backend/.env already exists, skipping"
fi
echo ""

# Check Python (optional for ML service)
echo "🐍 Checking Python (optional for ML service)..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "✅ Python found: $PYTHON_VERSION"
    echo "💡 To install ML service dependencies, run: cd ml_service && pip3 install -r requirements.txt"
elif command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version)
    echo "✅ Python found: $PYTHON_VERSION"
    echo "💡 To install ML service dependencies, run: cd ml_service && pip install -r requirements.txt"
else
    echo "⚠️  Python not found. ML service will not work without Python 3.9+"
    echo "💡 Install Python from https://www.python.org/downloads/"
fi
echo ""

echo "✨ Setup complete!"
echo ""
echo "📚 Next steps:"
echo "   1. Review and update environment files in frontend/.env.local and backend/.env"
echo "   2. Start the development servers:"
echo "      npm run start:all"
echo "   3. Or start services individually:"
echo "      - Backend: cd backend && npm run start:dev"
echo "      - Frontend: cd frontend && npm start"
echo ""
echo "📖 For more information, see SETUP.md"
echo ""
