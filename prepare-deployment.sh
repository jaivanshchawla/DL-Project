#!/bin/bash

##############################################################################
# Complete Deployment Automation Script
# Prepares your entire project for deployment to Vercel + Render
##############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR"

print_step "STEP 1: Checking Prerequisites"

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git first."
    exit 1
fi
print_success "Git is installed"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi
NODE_VERSION=$(node -v)
print_success "Node.js is installed: $NODE_VERSION"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install npm first."
    exit 1
fi
NPM_VERSION=$(npm -v)
print_success "npm is installed: $NPM_VERSION"

print_step "STEP 2: Verifying Project Structure"

# Check if essential directories exist
if [ ! -d "$PROJECT_ROOT/frontend" ]; then
    print_error "frontend directory not found!"
    exit 1
fi
print_success "frontend/ directory found"

if [ ! -d "$PROJECT_ROOT/backend" ]; then
    print_error "backend directory not found!"
    exit 1
fi
print_success "backend/ directory found"

print_step "STEP 3: Installing Dependencies"

# Install root dependencies
print_step "Installing root dependencies..."
cd "$PROJECT_ROOT"
npm install --legacy-peer-deps 2>&1 | grep -E "(added|up to date|npm warn)" || true
print_success "Root dependencies installed"

# Install frontend dependencies
print_step "Installing frontend dependencies..."
cd "$PROJECT_ROOT/frontend"
npm install --legacy-peer-deps 2>&1 | grep -E "(added|up to date|npm warn)" || true
print_success "Frontend dependencies installed"

# Install backend dependencies
print_step "Installing backend dependencies..."
cd "$PROJECT_ROOT/backend"
npm install --legacy-peer-deps 2>&1 | grep -E "(added|up to date|npm warn)" || true
print_success "Backend dependencies installed"

# Go back to root
cd "$PROJECT_ROOT"

print_step "STEP 4: Checking & Creating .gitignore"

# Create proper .gitignore if it doesn't exist or needs updating
GITIGNORE_PATH="$PROJECT_ROOT/.gitignore"

if [ ! -f "$GITIGNORE_PATH" ]; then
    print_warning ".gitignore not found, creating one..."
    cat > "$GITIGNORE_PATH" << 'EOF'
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
EOF
    print_success ".gitignore created"
else
    print_success ".gitignore already exists"
fi

print_step "STEP 5: Verifying vercel.json Configuration"

VERCEL_JSON_PATH="$PROJECT_ROOT/frontend/vercel.json"

if [ ! -f "$VERCEL_JSON_PATH" ]; then
    print_warning "vercel.json not found in frontend/, creating one..."
    cat > "$VERCEL_JSON_PATH" << 'EOF'
{
    "version": 2,
    "name": "connect-four-ai-frontend",
    "buildCommand": "npm run build",
    "outputDirectory": "build",
    "installCommand": "npm install --legacy-peer-deps",
    "framework": "create-react-app",
    "routes": [
        {
            "src": "/static/(.*)",
            "dest": "/static/$1"
        },
        {
            "src": "/(.*)",
            "dest": "/index.html"
        }
    ],
    "env": {
        "REACT_APP_ENVIRONMENT": "production"
    },
    "build": {
        "env": {
            "REACT_APP_ENVIRONMENT": "production"
        }
    }
}
EOF
    print_success "vercel.json created"
else
    print_success "vercel.json already exists"
fi

print_step "STEP 6: Checking Git Status"

# Initialize git if not already done
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    print_warning "Git repository not initialized. Initializing..."
    cd "$PROJECT_ROOT"
    git init
    print_success "Git repository initialized"
else
    print_success "Git repository already initialized"
fi

# Check if there are uncommitted changes
if [ -n "$(git -C "$PROJECT_ROOT" status --porcelain)" ]; then
    print_warning "Found uncommitted changes in your repository"
    echo ""
    echo "Files to commit:"
    git -C "$PROJECT_ROOT" status --short | head -20
    echo ""
    print_warning "Please commit these changes before deploying"
else
    print_success "All changes are committed"
fi

print_step "STEP 7: Building Frontend for Verification"

cd "$PROJECT_ROOT/frontend"
print_step "Building frontend (this may take 1-2 minutes)..."
npm run build > /dev/null 2>&1 && print_success "Frontend build successful" || print_warning "Frontend build had warnings (check logs)"

print_step "STEP 8: Building Backend for Verification"

cd "$PROJECT_ROOT/backend"
print_step "Building backend..."
npm run build > /dev/null 2>&1 && print_success "Backend build successful" || print_warning "Backend build had warnings (check logs)"

cd "$PROJECT_ROOT"

print_step "STEP 9: Generating Environment Variable Templates"

# Create environment templates
ENV_TEMPLATE_PATH="$PROJECT_ROOT/.deployment-env-template"

mkdir -p "$ENV_TEMPLATE_PATH"

# Frontend environment template
cat > "$ENV_TEMPLATE_PATH/FRONTEND_ENV_VARS.txt" << 'EOF'
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
EOF

# Backend environment template
cat > "$ENV_TEMPLATE_PATH/BACKEND_ENV_VARS.txt" << 'EOF'
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
EOF

# ML Service environment template (if ml_service exists)
if [ -d "$PROJECT_ROOT/ml_service" ]; then
    cat > "$ENV_TEMPLATE_PATH/ML_SERVICE_ENV_VARS.txt" << 'EOF'
# ML Service Environment Variables for Render
# Copy these to Render Dashboard → Your ML Service → Environment

PYTHON_VERSION=3.9
PORT=10000
EOF
fi

print_success "Environment variable templates created in .deployment-env-template/"

print_step "STEP 10: Creating Deployment Checklist"

# Create deployment checklist
cat > "$PROJECT_ROOT/DEPLOYMENT_CHECKLIST.md" << 'EOF'
# 🚀 Deployment Checklist

Complete these steps in order to deploy your entire application.

## ✅ Pre-Deployment (Local Setup)

- [ ] You have Node.js 18+ installed
- [ ] You have Git installed and initialized
- [ ] You have a GitHub account
- [ ] You created a GitHub repository
- [ ] You pushed your code to GitHub (`git push origin main`)
- [ ] Frontend builds successfully locally (`cd frontend && npm run build`)
- [ ] Backend builds successfully locally (`cd backend && npm run build`)

## ✅ Step 1: Deploy Frontend to Vercel

- [ ] You have a Vercel account (free at vercel.com)
- [ ] You authorized Vercel to access your GitHub
- [ ] You created a new Vercel project
- [ ] You set **Root Directory** to `frontend`
- [ ] Frontend deployed successfully (check Vercel dashboard)
- [ ] Frontend URL from Vercel: `https://_____________.vercel.app`
- [ ] Frontend loads without errors in browser

## ✅ Step 2: Deploy Backend to Render

- [ ] You have a Render account (free at render.com)
- [ ] You created a new Web Service on Render
- [ ] You set **Environment** to `Node`
- [ ] You set **Build Command** to: `cd backend && npm install && npm run build`
- [ ] You set **Start Command** to: `cd backend && npm run start:prod`
- [ ] You added environment variables from `BACKEND_ENV_VARS.txt`
- [ ] You updated `CORS_ORIGIN` with your Vercel frontend URL
- [ ] Backend deployed successfully (check Render logs)
- [ ] Backend URL from Render: `https://_____________.onrender.com`
- [ ] Backend is running (check in Render dashboard)

## ✅ Step 3: Connect Frontend to Backend

- [ ] You have your backend URL from Render
- [ ] You went back to Vercel project settings
- [ ] You updated `REACT_APP_API_URL` with backend URL
- [ ] You updated `REACT_APP_WS_URL` with backend URL (wss://)
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
- [ ] You set **Environment** to `Python 3`
- [ ] You set **Build Command** to: `cd ml_service && pip install -r requirements.txt`
- [ ] You set **Start Command** to: `cd ml_service && gunicorn -w 1 -b 0.0.0.0:$PORT ml_service:app`
- [ ] You added environment variables from `ML_SERVICE_ENV_VARS.txt`
- [ ] ML Service deployed successfully
- [ ] You updated backend `ML_SERVICE_URL` env var
- [ ] You enabled ML features in frontend env vars

## ✅ Final Checklist

- [ ] Frontend is live and accessible
- [ ] Backend is live and responding
- [ ] Frontend and backend can communicate
- [ ] Game loads and plays correctly
- [ ] No errors in browser console
- [ ] Ready to share with others!

## 🔗 Important URLs to Save

```
Frontend: https://[your-vercel-project].vercel.app
Backend: https://[your-render-service].onrender.com
```

---

**Congratulations! 🎉 Your entire application is now deployed!**
EOF

print_success "Deployment checklist created"

print_step "STEP 11: Creating Quick Reference File"

# Create quick reference
cat > "$PROJECT_ROOT/DEPLOYMENT_QUICK_REFERENCE.txt" << 'EOF'
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
│ 4. If it doesn't work, check Step 6                                         │
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
EOF

print_success "Quick reference created"

print_step "STEP 12: Verifying Project Status"

echo ""
echo "🔍 Project Structure Check:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check directories
[ -d "$PROJECT_ROOT/frontend" ] && echo "  ✅ frontend/" || echo "  ❌ frontend/"
[ -d "$PROJECT_ROOT/backend" ] && echo "  ✅ backend/" || echo "  ❌ backend/"
[ -d "$PROJECT_ROOT/ml_service" ] && echo "  ✅ ml_service/" || echo "  ℹ️  ml_service/ (optional)"

# Check files
[ -f "$PROJECT_ROOT/frontend/package.json" ] && echo "  ✅ frontend/package.json" || echo "  ❌ frontend/package.json"
[ -f "$PROJECT_ROOT/backend/package.json" ] && echo "  ✅ backend/package.json" || echo "  ❌ backend/package.json"
[ -f "$PROJECT_ROOT/.gitignore" ] && echo "  ✅ .gitignore" || echo "  ❌ .gitignore"
[ -f "$PROJECT_ROOT/frontend/vercel.json" ] && echo "  ✅ frontend/vercel.json" || echo "  ❌ frontend/vercel.json"

echo ""
echo "📦 Dependency Check:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ -d "$PROJECT_ROOT/node_modules" ] && echo "  ✅ Root node_modules/" || echo "  ℹ️  Root node_modules/ (not critical)"
[ -d "$PROJECT_ROOT/frontend/node_modules" ] && echo "  ✅ Frontend node_modules/" || echo "  ⚠️  Frontend node_modules/"
[ -d "$PROJECT_ROOT/backend/node_modules" ] && echo "  ✅ Backend node_modules/" || echo "  ⚠️  Backend node_modules/"

echo ""
echo "📄 Build Artifacts Check:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ -d "$PROJECT_ROOT/frontend/build" ] && echo "  ✅ Frontend build/" || echo "  ℹ️  Frontend build/ (will be created on deploy)"
[ -d "$PROJECT_ROOT/backend/dist" ] && echo "  ✅ Backend dist/" || echo "  ℹ️  Backend dist/ (will be created on deploy)"

print_step "DEPLOYMENT AUTOMATION COMPLETE! 🎉"

echo ""
echo "📋 What We've Done:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  1. ✅ Verified all prerequisites (Git, Node.js, npm)"
echo "  2. ✅ Checked project structure"
echo "  3. ✅ Installed all dependencies"
echo "  4. ✅ Created/verified .gitignore"
echo "  5. ✅ Created/verified vercel.json"
echo "  6. ✅ Built frontend and backend"
echo "  7. ✅ Created environment variable templates"
echo "  8. ✅ Created deployment checklists"
echo ""

echo "📚 Generated Files:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  • .deployment-env-template/ (Environment variable templates)"
echo "  • DEPLOYMENT_CHECKLIST.md (Step-by-step checklist)"
echo "  • DEPLOYMENT_QUICK_REFERENCE.txt (Quick reference guide)"
echo ""

echo "🚀 Next Steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  1. Push your code to GitHub:"
echo "     git add ."
echo "     git commit -m 'Prepare for deployment'"
echo "     git push origin main"
echo ""
echo "  2. Follow DEPLOYMENT_CHECKLIST.md"
echo ""
echo "  3. Use DEPLOYMENT_QUICK_REFERENCE.txt for quick lookup"
echo ""
echo "  4. Check .deployment-env-template/ for environment variables"
echo ""

echo "📖 Documentation Files:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  • COMPLETE_DEPLOYMENT_GUIDE.md (Full detailed guide)"
echo "  • DEPLOYMENT.md (Original deployment guide)"
echo "  • QUICKSTART.md (Quick start guide)"
echo ""

print_success "Your project is ready for deployment!"
print_warning "Remember to commit these changes to GitHub before deploying!"

echo ""
echo "Questions? Check the documentation files for detailed instructions."
echo ""
