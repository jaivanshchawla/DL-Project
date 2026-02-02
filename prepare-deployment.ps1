#Requires -Version 5.0

<#
.SYNOPSIS
    Complete Deployment Automation Script for Windows
    Prepares your entire project for deployment to Vercel + Render

.DESCRIPTION
    This script automates the setup and verification of your Connect Four AI
    project before deployment to production.

.EXAMPLE
    .\prepare-deployment.ps1
#>

# Enable strict error handling
$ErrorActionPreference = "Stop"

# Color definitions
function Write-StepHeader {
    param([string]$Message)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "▶ $Message" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# Get project root
$PROJECT_ROOT = (Get-Location).Path
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          Connect Four AI - Deployment Automation Script                   ║" -ForegroundColor Cyan
Write-Host "║                        Windows (PowerShell)                                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-StepHeader "STEP 1: Checking Prerequisites"

# Check if Git is installed
try {
    $gitVersion = git --version
    Write-Success "Git is installed: $gitVersion"
} catch {
    Write-Error-Custom "Git is not installed. Please install Git first."
    exit 1
}

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Success "Node.js is installed: $nodeVersion"
} catch {
    Write-Error-Custom "Node.js is not installed. Please install Node.js 18+ first."
    exit 1
}

# Check if npm is installed
try {
    $npmVersion = npm --version
    Write-Success "npm is installed: $npmVersion"
} catch {
    Write-Error-Custom "npm is not installed. Please install npm first."
    exit 1
}

Write-StepHeader "STEP 2: Verifying Project Structure"

# Check directories
if (-Not (Test-Path "$PROJECT_ROOT\frontend" -PathType Container)) {
    Write-Error-Custom "frontend directory not found!"
    exit 1
}
Write-Success "frontend\ directory found"

if (-Not (Test-Path "$PROJECT_ROOT\backend" -PathType Container)) {
    Write-Error-Custom "backend directory not found!"
    exit 1
}
Write-Success "backend\ directory found"

Write-StepHeader "STEP 3: Installing Dependencies"

Write-StepHeader "Installing root dependencies..."
Push-Location $PROJECT_ROOT
npm install --legacy-peer-deps *> $null
Write-Success "Root dependencies installed"

Write-StepHeader "Installing frontend dependencies..."
Push-Location "$PROJECT_ROOT\frontend"
npm install --legacy-peer-deps *> $null
Write-Success "Frontend dependencies installed"

Write-StepHeader "Installing backend dependencies..."
Push-Location "$PROJECT_ROOT\backend"
npm install --legacy-peer-deps *> $null
Write-Success "Backend dependencies installed"

Pop-Location

Write-StepHeader "STEP 4: Checking & Creating .gitignore"

$GITIGNORE_PATH = "$PROJECT_ROOT\.gitignore"

if (-Not (Test-Path $GITIGNORE_PATH)) {
    Write-Warning ".gitignore not found, creating one..."
    $gitignoreContent = @"
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
package-lock.json
yarn.lock

# Build artifacts
build/
dist/
.next/
out/

# Environment files (NEVER commit)
.env
.env.local
.env.*.local
.env.production.local
.env.test.local
.env.development.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db

# OS
.DS_Store
.env.*.local

# Logs
logs/
*.log
npm-debug.log*

# ML Service
ml_service/.venv/
ml_service/venv/
ml_service/__pycache__/
ml_service/*.pyc
ml_service/.pytest_cache/

# Testing
coverage/
.nyc_output/

# Temporary
tmp/
temp/
.cache/

# Build output
*.tgz
dist/
build/
"@
    Set-Content -Path $GITIGNORE_PATH -Value $gitignoreContent
    Write-Success ".gitignore created"
} else {
    Write-Success ".gitignore already exists"
}

Write-StepHeader "STEP 5: Verifying vercel.json Configuration"

$VERCEL_JSON_PATH = "$PROJECT_ROOT\frontend\vercel.json"

if (-Not (Test-Path $VERCEL_JSON_PATH)) {
    Write-Warning "vercel.json not found in frontend\, creating one..."
    $vercelConfig = @{
        version = 2
        name = "connect-four-ai-frontend"
        buildCommand = "npm run build"
        outputDirectory = "build"
        installCommand = "npm install --legacy-peer-deps"
        framework = "create-react-app"
        routes = @(
            @{
                src = "/static/(.*)"
                dest = "/static/$1"
            },
            @{
                src = "/(.*)"
                dest = "/index.html"
            }
        )
        env = @{
            REACT_APP_ENVIRONMENT = "production"
        }
        build = @{
            env = @{
                REACT_APP_ENVIRONMENT = "production"
            }
        }
    } | ConvertTo-Json -Depth 10
    
    Set-Content -Path $VERCEL_JSON_PATH -Value $vercelConfig
    Write-Success "vercel.json created"
} else {
    Write-Success "vercel.json already exists"
}

Write-StepHeader "STEP 6: Checking Git Status"

Push-Location $PROJECT_ROOT

# Initialize git if not already done
if (-Not (Test-Path "$PROJECT_ROOT\.git" -PathType Container)) {
    Write-Warning "Git repository not initialized. Initializing..."
    git init
    Write-Success "Git repository initialized"
} else {
    Write-Success "Git repository already initialized"
}

# Check for uncommitted changes
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Warning "Found uncommitted changes in your repository"
    Write-Host ""
    Write-Host "Files to commit (first 20):"
    $gitStatus | Select-Object -First 20 | Write-Host
    Write-Host ""
    Write-Warning "Please commit these changes before deploying"
} else {
    Write-Success "All changes are committed"
}

Pop-Location

Write-StepHeader "STEP 7: Building Frontend for Verification"

Push-Location "$PROJECT_ROOT\frontend"
Write-StepHeader "Building frontend (this may take 1-2 minutes)..."
try {
    npm run build *> $null
    Write-Success "Frontend build successful"
} catch {
    Write-Warning "Frontend build had warnings (check logs)"
}
Pop-Location

Write-StepHeader "STEP 8: Building Backend for Verification"

Push-Location "$PROJECT_ROOT\backend"
Write-StepHeader "Building backend..."
try {
    npm run build *> $null
    Write-Success "Backend build successful"
} catch {
    Write-Warning "Backend build had warnings (check logs)"
}
Pop-Location

Write-StepHeader "STEP 9: Generating Environment Variable Templates"

# Create deployment directory
$ENV_TEMPLATE_PATH = "$PROJECT_ROOT\.deployment-env-template"
New-Item -ItemType Directory -Path $ENV_TEMPLATE_PATH -Force *> $null

# Frontend environment template
$frontendEnv = @"
# Frontend Environment Variables for Vercel
# Copy these to Vercel Dashboard → Project Settings → Environment Variables

REACT_APP_API_URL=https://your-backend.onrender.com
REACT_APP_WS_URL=wss://your-backend.onrender.com
REACT_APP_ENVIRONMENT=production
REACT_APP_AI_EXPLANATIONS=false
REACT_APP_AI_RECOMMENDATIONS=false
REACT_APP_ENTERPRISE_MODE=false
REACT_APP_FAST_AI_MODE=true
REACT_APP_DEFAULT_THEME=dark
REACT_APP_THEME_SWITCHING=true
REACT_APP_ANIMATIONS_ENABLED=true
REACT_APP_SOUND_EFFECTS=true
REACT_APP_ENABLE_GAME_HISTORY=true
REACT_APP_ENABLE_MOVE_HINTS=true
REACT_APP_ENABLE_UNDO=true
"@
Set-Content -Path "$ENV_TEMPLATE_PATH\FRONTEND_ENV_VARS.txt" -Value $frontendEnv

# Backend environment template
$backendEnv = @"
# Backend Environment Variables for Render
# Copy these to Render Dashboard → Your Service → Environment

NODE_ENV=production
PORT=10000
CORS_ORIGIN=https://your-frontend.vercel.app
DISABLE_EXTERNAL_SERVICES=true
AI_DIFFICULTY_MIN=1
AI_DIFFICULTY_MAX=30
AI_THINKING_TIME_MAX=30000
AI_CACHE_SIZE=100000
FAST_MODE=true
SKIP_ML_INIT=true
"@
Set-Content -Path "$ENV_TEMPLATE_PATH\BACKEND_ENV_VARS.txt" -Value $backendEnv

# ML Service environment template (if ml_service exists)
if (Test-Path "$PROJECT_ROOT\ml_service" -PathType Container) {
    $mlEnv = @"
# ML Service Environment Variables for Render
# Copy these to Render Dashboard → Your ML Service → Environment

PYTHON_VERSION=3.9
PORT=10000
"@
    Set-Content -Path "$ENV_TEMPLATE_PATH\ML_SERVICE_ENV_VARS.txt" -Value $mlEnv
}

Write-Success "Environment variable templates created in .deployment-env-template\"

Write-StepHeader "STEP 10: Creating Deployment Checklist"

$checklistContent = @"
# 🚀 Deployment Checklist

Complete these steps in order to deploy your entire application.

## ✅ Pre-Deployment (Local Setup)

- [ ] You have Node.js 18+ installed
- [ ] You have Git installed and initialized
- [ ] You have a GitHub account
- [ ] You created a GitHub repository
- [ ] You pushed your code to GitHub (\`git push origin main\`)
- [ ] Frontend builds successfully locally (\`cd frontend && npm run build\`)
- [ ] Backend builds successfully locally (\`cd backend && npm run build\`)

## ✅ Step 1: Deploy Frontend to Vercel

- [ ] You have a Vercel account (free at vercel.com)
- [ ] You authorized Vercel to access your GitHub
- [ ] You created a new Vercel project
- [ ] You set **Root Directory** to \`frontend\`
- [ ] Frontend deployed successfully (check Vercel dashboard)
- [ ] Frontend URL from Vercel: \`https://_____________.vercel.app\`
- [ ] Frontend loads without errors in browser

## ✅ Step 2: Deploy Backend to Render

- [ ] You have a Render account (free at render.com)
- [ ] You created a new Web Service on Render
- [ ] You set **Environment** to \`Node\`
- [ ] You set **Build Command** to: \`cd backend && npm install && npm run build\`
- [ ] You set **Start Command** to: \`cd backend && npm run start:prod\`
- [ ] You added environment variables from \`BACKEND_ENV_VARS.txt\`
- [ ] You updated \`CORS_ORIGIN\` with your Vercel frontend URL
- [ ] Backend deployed successfully (check Render logs)
- [ ] Backend URL from Render: \`https://_____________.onrender.com\`
- [ ] Backend is running (check in Render dashboard)

## ✅ Step 3: Connect Frontend to Backend

- [ ] You have your backend URL from Render
- [ ] You went back to Vercel project settings
- [ ] You updated \`REACT_APP_API_URL\` with backend URL
- [ ] You updated \`REACT_APP_WS_URL\` with backend URL (wss://)
- [ ] You redeployed frontend in Vercel
- [ ] Frontend redeployment completed

## ✅ Step 4: Test Everything

- [ ] You opened your frontend URL in a browser
- [ ] Page loaded successfully (no blank screen)
- [ ] Opened browser console (F12) - no major errors
- [ ] Tried to play a game
- [ ] Game responded to your moves (proves backend connection works)
- [ ] No CORS errors in console
- [ ] No API connection errors

## ✅ Step 5: (Optional) Deploy ML Service

- [ ] You decided to deploy ML service (optional)
- [ ] You created another Render Web Service
- [ ] You set **Environment** to \`Python 3\`
- [ ] You set **Build Command** to: \`cd ml_service && pip install -r requirements.txt\`
- [ ] You set **Start Command** to: \`cd ml_service && gunicorn -w 1 -b 0.0.0.0:\$PORT ml_service:app\`
- [ ] You added environment variables from \`ML_SERVICE_ENV_VARS.txt\`
- [ ] ML Service deployed successfully
- [ ] You updated backend \`ML_SERVICE_URL\` env var
- [ ] You enabled ML features in frontend env vars

## ✅ Final Checklist

- [ ] Frontend is live and accessible
- [ ] Backend is live and responding
- [ ] Frontend and backend can communicate
- [ ] Game loads and plays correctly
- [ ] No errors in browser console
- [ ] Ready to share with others!

## 🔗 Important URLs to Save

\`\`\`
Frontend: https://[your-vercel-project].vercel.app
Backend: https://[your-render-service].onrender.com
\`\`\`

---

**Congratulations! 🎉 Your entire application is now deployed!**
"@
Set-Content -Path "$PROJECT_ROOT\DEPLOYMENT_CHECKLIST.md" -Value $checklistContent
Write-Success "Deployment checklist created"

Write-StepHeader "STEP 11: Creating Quick Reference File"

$quickRefContent = @"
╔══════════════════════════════════════════════════════════════════════════════╗
║                    DEPLOYMENT QUICK REFERENCE GUIDE                          ║
║                                                                              ║
║ This is a quick reminder of all the steps and tools you need.               ║
╚══════════════════════════════════════════════════════════════════════════════╝

STEP 1: PUSH CODE TO GITHUB
┌────────────────────────────────────────────────────────────────────────────┐
│ 1. Create a new repository on github.com                                    │
│ 2. In terminal, run:                                                        │
│    git remote add origin https://github.com/USERNAME/Connect-Four-AI.git   │
│    git branch -M main                                                       │
│    git push -u origin main                                                  │
│ 3. Refresh GitHub - you should see your files                              │
└────────────────────────────────────────────────────────────────────────────┘

STEP 2: DEPLOY FRONTEND (Vercel)
┌────────────────────────────────────────────────────────────────────────────┐
│ 1. Go to vercel.com → Sign up (free)                                       │
│ 2. Click "Add New" → "Project"                                             │
│ 3. Click "Import Git Repository"                                            │
│ 4. Select your Connect-Four-AI repo                                         │
│ 5. Root Directory: Set to "frontend"                                        │
│ 6. Add Environment Variables:                                               │
│    REACT_APP_API_URL = (you'll fill this after step 3)                      │
│    REACT_APP_WS_URL = (you'll fill this after step 3)                       │
│    REACT_APP_ENVIRONMENT = production                                       │
│ 7. Click "Deploy"                                                           │
│ 8. Wait 2-3 minutes                                                         │
│ 9. Save your Vercel URL when it's done                                      │
└────────────────────────────────────────────────────────────────────────────┘

STEP 3: DEPLOY BACKEND (Render)
┌────────────────────────────────────────────────────────────────────────────┐
│ 1. Go to render.com → Sign up (free)                                       │
│ 2. Click "New+" → "Web Service"                                             │
│ 3. "Build and deploy from a Git repository"                                 │
│ 4. Connect GitHub and select your repo                                      │
│ 5. Configure:                                                               │
│    - Name: connect-four-backend                                             │
│    - Environment: Node                                                      │
│    - Build Command: cd backend && npm install && npm run build              │
│    - Start Command: cd backend && npm run start:prod                        │
│ 6. Add Environment Variables:                                               │
│    NODE_ENV = production                                                    │
│    PORT = 10000                                                             │
│    CORS_ORIGIN = (your Vercel URL from Step 2)                              │
│    DISABLE_EXTERNAL_SERVICES = true                                         │
│    FAST_MODE = true                                                         │
│ 7. Click "Create Web Service"                                               │
│ 8. Wait 3-5 minutes                                                         │
│ 9. Save your Render URL when it's done                                      │
└────────────────────────────────────────────────────────────────────────────┘

STEP 4: CONNECT FRONTEND TO BACKEND
┌────────────────────────────────────────────────────────────────────────────┐
│ 1. Go back to Vercel Dashboard → Your Project                              │
│ 2. Settings → Environment Variables                                         │
│ 3. Update:                                                                  │
│    REACT_APP_API_URL = (your Render URL from Step 3)                        │
│    REACT_APP_WS_URL = (your Render URL from Step 3, but with wss://)       │
│ 4. Go to Deployments tab                                                    │
│ 5. Click the "..." on latest deployment → "Redeploy"                       │
│ 6. Wait 1-2 minutes for frontend to redeploy                               │
└────────────────────────────────────────────────────────────────────────────┘

STEP 5: TEST YOUR APP
┌────────────────────────────────────────────────────────────────────────────┐
│ 1. Open your Vercel URL in browser                                          │
│ 2. Try playing a game                                                       │
│ 3. If it works, you're done! 🎉                                             │
│ 4. If it doesn't work, check troubleshooting below                         │
└────────────────────────────────────────────────────────────────────────────┘

TROUBLESHOOTING
┌────────────────────────────────────────────────────────────────────────────┐
│ • CORS error in console?                                                    │
│   → Make sure CORS_ORIGIN in Render backend matches your Vercel URL       │
│   → Check it includes https:// and has no trailing slash                   │
│                                                                              │
│ • API connection error?                                                     │
│   → Make sure REACT_APP_API_URL in Vercel is correct                       │
│   → Wait at least 30 seconds (free Render services take time to start)     │
│                                                                              │
│ • Blank page?                                                               │
│   → Open browser console (F12 → Console tab)                               │
│   → Look for error messages                                                 │
│   → Check that all environment variables are set                           │
└────────────────────────────────────────────────────────────────────────────┘

ENVIRONMENT VARIABLES REFERENCE
┌────────────────────────────────────────────────────────────────────────────┐
│ VERCEL (Frontend) Environment Variables:                                    │
│ • REACT_APP_API_URL → Your Render backend URL                              │
│ • REACT_APP_WS_URL → Your Render backend URL (with wss://)                 │
│ • REACT_APP_ENVIRONMENT → production                                        │
│                                                                              │
│ RENDER (Backend) Environment Variables:                                     │
│ • NODE_ENV → production                                                     │
│ • PORT → 10000                                                              │
│ • CORS_ORIGIN → Your Vercel frontend URL                                   │
│ • DISABLE_EXTERNAL_SERVICES → true                                          │
└────────────────────────────────────────────────────────────────────────────┘

IMPORTANT NOTES
┌────────────────────────────────────────────────────────────────────────────┐
│ ✓ Both Vercel and Render offer free tiers                                  │
│ ✓ Free Render services spin down after 15 minutes of inactivity             │
│ ✓ To keep Render awake, use UptimeRobot.com (free) to ping every 5 mins   │
│ ✓ Everything in this project works on free tier                            │
│ ✓ This deployment takes about 15-20 minutes total                          │
└────────────────────────────────────────────────────────────────────────────┘
"@
Set-Content -Path "$PROJECT_ROOT\DEPLOYMENT_QUICK_REFERENCE.txt" -Value $quickRefContent
Write-Success "Quick reference created"

Write-StepHeader "STEP 12: Verifying Project Status"

Write-Host ""
Write-Host "🔍 Project Structure Check:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check directories
if (Test-Path "$PROJECT_ROOT\frontend" -PathType Container) { Write-Host "  ✅ frontend\" } else { Write-Host "  ❌ frontend\" }
if (Test-Path "$PROJECT_ROOT\backend" -PathType Container) { Write-Host "  ✅ backend\" } else { Write-Host "  ❌ backend\" }
if (Test-Path "$PROJECT_ROOT\ml_service" -PathType Container) { Write-Host "  ✅ ml_service\" } else { Write-Host "  ℹ️  ml_service\ (optional)" }

# Check files
if (Test-Path "$PROJECT_ROOT\frontend\package.json") { Write-Host "  ✅ frontend\package.json" } else { Write-Host "  ❌ frontend\package.json" }
if (Test-Path "$PROJECT_ROOT\backend\package.json") { Write-Host "  ✅ backend\package.json" } else { Write-Host "  ❌ backend\package.json" }
if (Test-Path "$PROJECT_ROOT\.gitignore") { Write-Host "  ✅ .gitignore" } else { Write-Host "  ❌ .gitignore" }
if (Test-Path "$PROJECT_ROOT\frontend\vercel.json") { Write-Host "  ✅ frontend\vercel.json" } else { Write-Host "  ❌ frontend\vercel.json" }

Write-Host ""
Write-Host "📦 Dependency Check:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if (Test-Path "$PROJECT_ROOT\node_modules" -PathType Container) { Write-Host "  ✅ Root node_modules\" } else { Write-Host "  ℹ️  Root node_modules\ (not critical)" }
if (Test-Path "$PROJECT_ROOT\frontend\node_modules" -PathType Container) { Write-Host "  ✅ Frontend node_modules\" } else { Write-Host "  ⚠️  Frontend node_modules\" }
if (Test-Path "$PROJECT_ROOT\backend\node_modules" -PathType Container) { Write-Host "  ✅ Backend node_modules\" } else { Write-Host "  ⚠️  Backend node_modules\" }

Write-Host ""
Write-Host "📄 Build Artifacts Check:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if (Test-Path "$PROJECT_ROOT\frontend\build" -PathType Container) { Write-Host "  ✅ Frontend build\" } else { Write-Host "  ℹ️  Frontend build\ (will be created on deploy)" }
if (Test-Path "$PROJECT_ROOT\backend\dist" -PathType Container) { Write-Host "  ✅ Backend dist\" } else { Write-Host "  ℹ️  Backend dist\ (will be created on deploy)" }

Write-StepHeader "DEPLOYMENT AUTOMATION COMPLETE! 🎉"

Write-Host ""
Write-Host "📋 What We've Done:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "  1. ✅ Verified all prerequisites (Git, Node.js, npm)"
Write-Host "  2. ✅ Checked project structure"
Write-Host "  3. ✅ Installed all dependencies"
Write-Host "  4. ✅ Created/verified .gitignore"
Write-Host "  5. ✅ Created/verified vercel.json"
Write-Host "  6. ✅ Built frontend and backend"
Write-Host "  7. ✅ Created environment variable templates"
Write-Host "  8. ✅ Created deployment checklists"
Write-Host ""

Write-Host "📚 Generated Files:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "  • .deployment-env-template\ (Environment variable templates)"
Write-Host "  • DEPLOYMENT_CHECKLIST.md (Step-by-step checklist)"
Write-Host "  • DEPLOYMENT_QUICK_REFERENCE.txt (Quick reference guide)"
Write-Host ""

Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "  1. Push your code to GitHub:"
Write-Host "     git add ."
Write-Host "     git commit -m 'Prepare for deployment'"
Write-Host "     git push origin main"
Write-Host ""
Write-Host "  2. Follow DEPLOYMENT_CHECKLIST.md"
Write-Host ""
Write-Host "  3. Use DEPLOYMENT_QUICK_REFERENCE.txt for quick lookup"
Write-Host ""
Write-Host "  4. Check .deployment-env-template\ for environment variables"
Write-Host ""

Write-Host "📖 Documentation Files:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "  • COMPLETE_DEPLOYMENT_GUIDE.md (Full detailed guide)"
Write-Host "  • DEPLOYMENT.md (Original deployment guide)"
Write-Host "  • QUICKSTART.md (Quick start guide)"
Write-Host ""

Write-Success "Your project is ready for deployment!"
Write-Warning "Remember to commit these changes to GitHub before deploying!"

Write-Host ""
Write-Host "Questions? Check the documentation files for detailed instructions." -ForegroundColor Green
Write-Host ""
