#Requires -Version 5.0

<#
.SYNOPSIS
    Ultimate Automated Deployment Script for Windows
    Deploys entire Connect Four AI to Vercel + Render with minimal input

.DESCRIPTION
    This script automates the entire deployment process.
    Your input is only needed for authentication (2 logins, ~1 minute total).

.EXAMPLE
    .\deploy-automated.ps1
#>

$ErrorActionPreference = "Stop"

# Colors
$colors = @{
    Red    = "Red"
    Green  = "Green"
    Yellow = "Yellow"
    Cyan   = "Cyan"
    Blue   = "Blue"
}

# Configuration
$PROJECT_ROOT = (Get-Location).Path
$PROJECT_NAME = "connect-four-ai"
$VERCEL_PROJECT_NAME = "connect-four-ai-frontend"
$RENDER_SERVICE_NAME = "connect-four-backend"

# Helper functions
function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "▶ $Message" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "► $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-InputNeeded {
    param([string]$Message)
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║                    👤 INPUT NEEDED                         ║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host $Message -ForegroundColor Yellow
    Write-Host ""
}

# Main deployment
Write-Header "ULTIMATE AUTOMATED DEPLOYMENT"

Write-Host "This script will deploy your entire application with minimal input."
Write-Host "You'll only need to authenticate twice (Vercel and Render)."
Write-Host ""

# Step 1: Verify prerequisites
Write-Step "STEP 1: Verifying Prerequisites"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-ErrorMsg "Git not installed"
    exit 1
}
Write-Success "Git installed"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-ErrorMsg "Node.js not installed"
    exit 1
}
$nodeVersion = node --version
Write-Success "Node.js installed ($nodeVersion)"

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-ErrorMsg "npm not installed"
    exit 1
}
$npmVersion = npm --version
Write-Success "npm installed ($npmVersion)"

# Step 2: Check GitHub setup
Write-Step "STEP 2: Verifying GitHub Setup"

Push-Location $PROJECT_ROOT

if (-not (Test-Path ".git")) {
    Write-Warning "Git not initialized. Initializing..."
    git init
}

$REMOTE_URL = git config --get remote.origin.url 2>$null
if (-not $REMOTE_URL) {
    Write-InputNeeded @"
📝 YOUR INPUT NEEDED:

Your project doesn't have a GitHub remote URL set.

Run this command in your project folder:
  git remote add origin https://github.com/YOUR_USERNAME/$PROJECT_NAME.git

Then come back and run this script again.
"@
    exit 1
}

Write-Success "GitHub remote configured: $REMOTE_URL"

# Step 3: Build projects
Write-Step "STEP 3: Building Projects"

Write-Step "Building frontend..."
Push-Location "$PROJECT_ROOT\frontend"
npm run build *>$null
Write-Success "Frontend built"
Pop-Location

Write-Step "Building backend..."
Push-Location "$PROJECT_ROOT\backend"
npm run build *>$null
Write-Success "Backend built"
Pop-Location

# Step 4: Push to GitHub
Write-Step "STEP 4: Pushing to GitHub"

git add . 2>$null
git commit -m "Automated deployment push - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 2>$null
git push origin main

Write-Success "Code pushed to GitHub"

# Step 5: Install Vercel CLI
Write-Step "STEP 5: Setting up Vercel CLI"

if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
    Write-Step "Installing Vercel CLI..."
    npm install -g vercel *>$null
    Write-Success "Vercel CLI installed"
} else {
    Write-Success "Vercel CLI already installed"
}

# Step 6: Vercel Login & Deploy
Write-Step "STEP 6: Deploying to Vercel (Frontend)"

Write-InputNeeded @"
🔐 VERCEL AUTHENTICATION REQUIRED

A browser window will open for Vercel login.
This takes about 30 seconds.

Press ENTER when ready...
"@
Read-Host

Push-Location "$PROJECT_ROOT\frontend"

# Check if already logged in
$vercelAuthPath = "$env:USERPROFILE\.vercel\auth.json"
if (-not (Test-Path $vercelAuthPath)) {
    vercel login
} else {
    Write-Success "Already authenticated with Vercel"
}

Write-Step "Deploying frontend to Vercel..."

# Deploy with production flag
$vercelOutput = vercel --prod 2>&1
Write-Host $vercelOutput

# Try to extract URL
$VERCEL_URL = $vercelOutput | Select-String "Production:" | Select-Object -First 1
if ($VERCEL_URL) {
    $VERCEL_URL = $VERCEL_URL.ToString().Split(":")[-1].Trim()
} else {
    $VERCEL_URL = ""
}

Write-Success "Frontend deployed to Vercel"

if ($VERCEL_URL) {
    Write-Success "Vercel URL: $VERCEL_URL"
} else {
    Write-InputNeeded @"
📝 MANUAL STEP:

Could not auto-detect Vercel URL.

Go to vercel.com dashboard and copy your project URL.
It should look like: https://project-name.vercel.app

Save it and enter it:
"@
    $VERCEL_URL = Read-Host "Enter your Vercel URL"
}

Pop-Location

# Step 7: Render API Deploy
Write-Step "STEP 7: Deploying to Render (Backend)"

Write-InputNeeded @"
🔐 RENDER API KEY REQUIRED

1. Go to: https://dashboard.render.com/account/api-tokens
2. Click 'Create API Key'
3. Copy the API key

Paste your Render API key:
"@
$RENDER_API_KEY = Read-Host -AsSecureString
$RENDER_API_KEY_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUni($RENDER_API_KEY))

if (-not $RENDER_API_KEY_PLAIN) {
    Write-ErrorMsg "No API key provided"
    exit 1
}

Write-Step "Creating Render service..."

# Create web service via Render API
$renderBody = @{
    name             = $RENDER_SERVICE_NAME
    type             = "web_service"
    environmentId    = "node"
    repo             = $REMOTE_URL
    branch           = "main"
    buildCommand     = "cd backend && npm install && npm run build"
    startCommand     = "cd backend && npm run start:prod"
    region           = "oregon"
    plan             = "free"
    envVars          = @(
        @{ key = "NODE_ENV"; value = "production" }
        @{ key = "CORS_ORIGIN"; value = $VERCEL_URL }
        @{ key = "DISABLE_EXTERNAL_SERVICES"; value = "true" }
        @{ key = "FAST_MODE"; value = "true" }
    )
} | ConvertTo-Json

try {
    $RENDER_RESPONSE = Invoke-WebRequest -Uri "https://api.render.com/v1/services" `
        -Headers @{ "authorization" = "Bearer $RENDER_API_KEY_PLAIN"; "Content-Type" = "application/json" } `
        -Body $renderBody `
        -Method POST -ErrorAction Stop
    
    $RENDER_JSON = $RENDER_RESPONSE.Content | ConvertFrom-Json
    $RENDER_ID = $RENDER_JSON.id
    $RENDER_ERROR = $RENDER_JSON.error
    
    if ($RENDER_ERROR) {
        throw $RENDER_ERROR
    }
    
    Write-Success "Render service created: $RENDER_ID"
    $RENDER_MANUAL_DEPLOY = $false
} catch {
    Write-ErrorMsg "Render API error: $_"
    Write-InputNeeded @"
⚠️  MANUAL STEP REQUIRED:

1. Go to: https://render.com/dashboard
2. Click 'New +' → 'Web Service'
3. Connect your GitHub repo
4. Use these settings:
   - Build Command: cd backend && npm install && npm run build
   - Start Command: cd backend && npm run start:prod
   
Environment Variables to add:
   NODE_ENV = production
   CORS_ORIGIN = $VERCEL_URL
   DISABLE_EXTERNAL_SERVICES = true
   FAST_MODE = true
"@
    $RENDER_MANUAL_DEPLOY = $true
}

# Step 8: Connect Frontend to Backend
Write-Step "STEP 8: Connecting Frontend to Backend"

if (-not $RENDER_MANUAL_DEPLOY) {
    $RENDER_URL = "https://$RENDER_SERVICE_NAME.onrender.com"
    Write-Success "Backend URL: $RENDER_URL"
    
    Write-Step "Updating Vercel environment variables..."
    
    Push-Location "$PROJECT_ROOT\frontend"
    
    vercel env add REACT_APP_API_URL $RENDER_URL
    vercel env add REACT_APP_WS_URL "wss://$RENDER_URL"
    
    Write-Step "Redeploying frontend with backend connection..."
    vercel --prod *>$null
    
    Pop-Location
    
    Write-Success "Frontend connected to backend and redeployed"
} else {
    Write-InputNeeded @"
After you've set up Render manually:

1. Get your Render backend URL from the dashboard
2. Go to Vercel dashboard
3. Add environment variables:
   REACT_APP_API_URL = https://your-render-service.onrender.com
   REACT_APP_WS_URL = wss://your-render-service.onrender.com
4. Redeploy frontend
"@
}

Pop-Location

# Step 9: Summary
Write-Header "DEPLOYMENT COMPLETE! 🎉"

Write-Host ""
Write-Host "Your application is now deployed!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Frontend URL: $VERCEL_URL"
Write-Host "📍 Backend URL: https://$RENDER_SERVICE_NAME.onrender.com"
Write-Host ""
Write-Host "⏳ Services may take 1-2 minutes to fully initialize."
Write-Host "   Free tier services spin down after 15 minutes of inactivity."
Write-Host ""
Write-Host "Testing: Open in your browser and try playing!"
Write-Host ""
Write-Host "Dashboards:"
Write-Host "   • Vercel: https://vercel.com/dashboard"
Write-Host "   • Render: https://render.com/dashboard"
Write-Host ""
Write-Success "Deployment automation complete!"
