# Connect Four AI - Setup Script for Windows
# This script sets up the project for local development

Write-Host "🚀 Setting up Connect Four AI..." -ForegroundColor Green
Write-Host ""

# Check Node.js
Write-Host "📦 Checking Node.js..." -ForegroundColor Yellow
$nodeVersion = node --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Node.js is not installed. Please install Node.js 18+ from https://nodejs.org/" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Node.js version: $nodeVersion" -ForegroundColor Green

# Check npm
Write-Host "📦 Checking npm..." -ForegroundColor Yellow
$npmVersion = npm --version
Write-Host "✅ npm version: $npmVersion" -ForegroundColor Green
Write-Host ""

# Install root dependencies
Write-Host "📦 Installing root dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install root dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Root dependencies installed" -ForegroundColor Green
Write-Host ""

# Install frontend dependencies
Write-Host "📦 Installing frontend dependencies..." -ForegroundColor Yellow
Set-Location frontend
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install frontend dependencies" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Frontend dependencies installed" -ForegroundColor Green
Set-Location ..
Write-Host ""

# Install backend dependencies
Write-Host "📦 Installing backend dependencies..." -ForegroundColor Yellow
Set-Location backend
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install backend dependencies" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Write-Host "✅ Backend dependencies installed" -ForegroundColor Green
Set-Location ..
Write-Host ""

# Create environment files
Write-Host "📝 Creating environment files..." -ForegroundColor Yellow

# Frontend .env.local
if (-not (Test-Path "frontend\.env.local")) {
    if (Test-Path "frontend\.env.example") {
        Copy-Item "frontend\.env.example" "frontend\.env.local"
        Write-Host "✅ Created frontend/.env.local from .env.example" -ForegroundColor Green
    } else {
        Write-Host "⚠️  frontend/.env.example not found. Creating default .env.local" -ForegroundColor Yellow
        @"
REACT_APP_API_URL=http://localhost:3000
REACT_APP_WS_URL=ws://localhost:3000
REACT_APP_ML_SERVICE_URL=http://localhost:8000
REACT_APP_ENVIRONMENT=development
REACT_APP_VERSION=1.0.0
REACT_APP_ANALYTICS_ENABLED=false
"@ | Out-File -FilePath "frontend\.env.local" -Encoding utf8
        Write-Host "✅ Created frontend/.env.local" -ForegroundColor Green
    }
} else {
    Write-Host "ℹ️  frontend/.env.local already exists, skipping" -ForegroundColor Cyan
}

# Backend .env
if (-not (Test-Path "backend\.env")) {
    if (Test-Path "backend\.env.example") {
        Copy-Item "backend\.env.example" "backend\.env"
        Write-Host "✅ Created backend/.env from .env.example" -ForegroundColor Green
    } else {
        Write-Host "⚠️  backend/.env.example not found. Creating default .env" -ForegroundColor Yellow
        @"
NODE_ENV=development
PORT=3000
CORS_ORIGIN=http://localhost:3001
"@ | Out-File -FilePath "backend\.env" -Encoding utf8
        Write-Host "✅ Created backend/.env" -ForegroundColor Green
    }
} else {
    Write-Host "ℹ️  backend/.env already exists, skipping" -ForegroundColor Cyan
}
Write-Host ""

# Check Python (optional for ML service)
Write-Host "🐍 Checking Python (optional for ML service)..." -ForegroundColor Yellow
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
    Write-Host "💡 To install ML service dependencies, run: cd ml_service && pip install -r requirements.txt" -ForegroundColor Cyan
} else {
    Write-Host "⚠️  Python not found. ML service will not work without Python 3.9+" -ForegroundColor Yellow
    Write-Host "💡 Install Python from https://www.python.org/downloads/" -ForegroundColor Cyan
}
Write-Host ""

Write-Host "✨ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Review and update environment files in frontend/.env.local and backend/.env" -ForegroundColor White
Write-Host "   2. Start the development servers:" -ForegroundColor White
Write-Host "      npm run start:all" -ForegroundColor Cyan
Write-Host "   3. Or start services individually:" -ForegroundColor White
Write-Host "      - Backend: cd backend && npm run start:dev" -ForegroundColor Cyan
Write-Host "      - Frontend: cd frontend && npm start" -ForegroundColor Cyan
Write-Host ""
Write-Host "📖 For more information, see SETUP.md" -ForegroundColor Yellow
Write-Host ""
