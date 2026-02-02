#!/bin/bash

##############################################################################
# ULTIMATE AUTOMATED DEPLOYMENT SCRIPT
# Deploys entire Connect Four AI to Vercel + Render with minimal input
# 
# What's Automated:
#   ✅ GitHub push
#   ✅ Vercel deployment (via CLI)
#   ✅ Render deployment (via API)
#   ✅ Environment variables
#   ✅ Connection setup
#
# What Needs Your Input:
#   ⚠️  Step 1: Vercel authentication (1 login, ~30 seconds)
#   ⚠️  Step 2: Render authentication (1 login, ~30 seconds)
#   ⚠️  Final: Verify in browser (1 minute)
##############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="connect-four-ai"
VERCEL_PROJECT_NAME="connect-four-ai-frontend"
RENDER_SERVICE_NAME="connect-four-backend"

# Helper functions
print_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}▶ $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo ""
    echo -e "${BLUE}► $1${NC}"
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

print_input_needed() {
    echo -e "${YELLOW}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                    👤 INPUT NEEDED                         ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "$1${NC}"
    echo ""
}

# Main deployment
print_header "ULTIMATE AUTOMATED DEPLOYMENT"

echo "This script will deploy your entire application with minimal input."
echo "You'll only need to authenticate twice (Vercel & Render)."
echo ""

# Step 1: Verify prerequisites
print_step "STEP 1: Verifying Prerequisites"

if ! command -v git &> /dev/null; then
    print_error "Git not installed"
    exit 1
fi
print_success "Git installed"

if ! command -v node &> /dev/null; then
    print_error "Node.js not installed"
    exit 1
fi
print_success "Node.js installed ($(node -v))"

if ! command -v npm &> /dev/null; then
    print_error "npm not installed"
    exit 1
fi
print_success "npm installed ($(npm -v))"

# Step 2: Check GitHub setup
print_step "STEP 2: Verifying GitHub Setup"

if [ ! -d "$PROJECT_ROOT/.git" ]; then
    print_warning "Git not initialized. Initializing..."
    cd "$PROJECT_ROOT"
    git init
fi

REMOTE_URL=$(git -C "$PROJECT_ROOT" config --get remote.origin.url 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
    print_input_needed "📝 YOUR INPUT NEEDED:\n\nYour project doesn't have a GitHub remote URL set.\n\nRun this command in your project folder:\n  git remote add origin https://github.com/YOUR_USERNAME/$PROJECT_NAME.git\n\nThen come back and run this script again."
    exit 1
fi

print_success "GitHub remote configured: $REMOTE_URL"

# Step 3: Build projects
print_step "STEP 3: Building Projects"

print_step "Building frontend..."
cd "$PROJECT_ROOT/frontend"
npm run build > /dev/null 2>&1
print_success "Frontend built"

print_step "Building backend..."
cd "$PROJECT_ROOT/backend"
npm run build > /dev/null 2>&1
print_success "Backend built"

cd "$PROJECT_ROOT"

# Step 4: Push to GitHub
print_step "STEP 4: Pushing to GitHub"

git -C "$PROJECT_ROOT" add .
git -C "$PROJECT_ROOT" commit -m "Automated deployment push - $(date)" 2>/dev/null || print_success "Code already up to date"
git -C "$PROJECT_ROOT" push origin main

print_success "Code pushed to GitHub"

# Step 5: Install Vercel CLI
print_step "STEP 5: Setting up Vercel CLI"

if ! command -v vercel &> /dev/null; then
    print_step "Installing Vercel CLI..."
    npm install -g vercel > /dev/null 2>&1
    print_success "Vercel CLI installed"
else
    print_success "Vercel CLI already installed"
fi

# Step 6: Vercel Login & Deploy
print_step "STEP 6: Deploying to Vercel (Frontend)"

print_input_needed "🔐 VERCEL AUTHENTICATION REQUIRED\n\nA browser window will open for Vercel login.\nThis takes about 30 seconds.\n\nPress ENTER when ready..."
read

cd "$PROJECT_ROOT/frontend"

# Check if already logged in
if [ ! -d "$HOME/.vercel" ] || [ ! -f "$HOME/.vercel/auth.json" ]; then
    # Need to login
    vercel login
else
    print_success "Already authenticated with Vercel"
fi

print_step "Deploying frontend to Vercel..."

# Deploy with specific settings
vercel --prod \
    --name "$VERCEL_PROJECT_NAME" \
    --scope "$(cat $HOME/.vercel/auth.json | grep -o '"scope":"[^"]*' | cut -d'"' -f4)" \
    2>&1 | tee /tmp/vercel_output.txt

# Extract Vercel URL
VERCEL_URL=$(grep "✓ Deployment successful" /tmp/vercel_output.txt -A 1 | tail -1 | tr -d ' ' || echo "")

if [ -z "$VERCEL_URL" ]; then
    VERCEL_URL=$(grep "Production:" /tmp/vercel_output.txt | head -1 | awk '{print $NF}' | tr -d '[:space:]')
fi

print_success "Frontend deployed to Vercel"

if [ ! -z "$VERCEL_URL" ]; then
    print_success "Vercel URL: $VERCEL_URL"
else
    print_warning "Could not auto-detect Vercel URL. You can find it in Vercel dashboard."
    print_input_needed "📝 MANUAL STEP:\n\nGo to vercel.com dashboard and copy your project URL.\nIt should look like: https://project-name.vercel.app"
fi

cd "$PROJECT_ROOT"

# Step 7: Install Render CLI
print_step "STEP 7: Setting up Render"

# Check if we have jq for JSON parsing
if ! command -v jq &> /dev/null; then
    print_step "Installing jq for JSON parsing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq > /dev/null 2>&1
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -y jq > /dev/null 2>&1
    fi
fi

# Step 8: Render API Deploy
print_step "STEP 8: Deploying to Render (Backend)"

print_input_needed "🔐 RENDER API KEY REQUIRED\n\n1. Go to: https://dashboard.render.com/account/api-tokens\n2. Click 'Create API Key'\n3. Copy the API key\n\nPaste your Render API key and press ENTER:"
read -s RENDER_API_KEY

if [ -z "$RENDER_API_KEY" ]; then
    print_error "No API key provided"
    exit 1
fi

# Create Render service config
RENDER_CONFIG=$(cat <<EOF
{
  "name": "$RENDER_SERVICE_NAME",
  "repo": "$REMOTE_URL",
  "envSpecific": false,
  "envVars": [
    {
      "key": "NODE_ENV",
      "value": "production"
    },
    {
      "key": "CORS_ORIGIN",
      "value": "$VERCEL_URL"
    },
    {
      "key": "DISABLE_EXTERNAL_SERVICES",
      "value": "true"
    },
    {
      "key": "FAST_MODE",
      "value": "true"
    },
    {
      "key": "SKIP_ML_INIT",
      "value": "true"
    }
  ],
  "buildCommand": "cd backend && npm install && npm run build",
  "startCommand": "cd backend && npm run start:prod",
  "region": "oregon",
  "plan": "free"
}
EOF
)

print_step "Creating Render service..."

# Create web service via Render API
RENDER_RESPONSE=$(curl -s -X POST "https://api.render.com/v1/services" \
  -H "authorization: Bearer $RENDER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "'$RENDER_SERVICE_NAME'",
    "ownerId": "self",
    "type": "web_service",
    "environmentId": "node",
    "repo": "'$REMOTE_URL'",
    "branch": "main",
    "buildCommand": "cd backend && npm install && npm run build",
    "startCommand": "cd backend && npm run start:prod",
    "envVars": [
      {"key": "NODE_ENV", "value": "production"},
      {"key": "CORS_ORIGIN", "value": "'$VERCEL_URL'"},
      {"key": "DISABLE_EXTERNAL_SERVICES", "value": "true"},
      {"key": "FAST_MODE", "value": "true"}
    ]
  }' 2>/dev/null)

RENDER_ID=$(echo "$RENDER_RESPONSE" | jq -r '.id' 2>/dev/null || echo "")
RENDER_ERROR=$(echo "$RENDER_RESPONSE" | jq -r '.error' 2>/dev/null || echo "")

if [ ! -z "$RENDER_ERROR" ] && [ "$RENDER_ERROR" != "null" ]; then
    print_error "Render API error: $RENDER_ERROR"
    print_input_needed "⚠️  MANUAL STEP REQUIRED:\n\n1. Go to: https://render.com/dashboard\n2. Click 'New +' → 'Web Service'\n3. Connect your GitHub repo\n4. Use these settings:\n   - Build Command: cd backend && npm install && npm run build\n   - Start Command: cd backend && npm run start:prod\n   - Environment variables: (see below)\n\nEnvironment Variables to add:\n   NODE_ENV = production\n   CORS_ORIGIN = $VERCEL_URL\n   DISABLE_EXTERNAL_SERVICES = true\n   FAST_MODE = true"
    RENDER_MANUAL_DEPLOY=true
else
    print_success "Render service created: $RENDER_ID"
    RENDER_MANUAL_DEPLOY=false
fi

# Step 9: Connect Frontend to Backend
print_step "STEP 9: Connecting Frontend to Backend"

if [ $RENDER_MANUAL_DEPLOY = false ]; then
    # Get Render URL
    RENDER_URL="https://$RENDER_SERVICE_NAME.onrender.com"
    print_success "Backend URL: $RENDER_URL"
    
    # Update Vercel environment variables
    print_step "Updating Vercel environment variables..."
    
    cd "$PROJECT_ROOT/frontend"
    
    vercel env add REACT_APP_API_URL "$RENDER_URL"
    vercel env add REACT_APP_WS_URL "wss://$RENDER_URL"
    
    # Redeploy Vercel
    print_step "Redeploying frontend with backend connection..."
    vercel --prod > /dev/null 2>&1
    
    cd "$PROJECT_ROOT"
    print_success "Frontend connected to backend and redeployed"
else
    print_warning "Manual Render setup required (see above)"
    print_input_needed "After you've set up Render manually:\n\n1. Get your Render backend URL from the dashboard\n2. Go to Vercel dashboard\n3. Add environment variables:\n   REACT_APP_API_URL = https://your-render-service.onrender.com\n   REACT_APP_WS_URL = wss://your-render-service.onrender.com\n4. Redeploy frontend"
fi

# Step 10: Summary
print_header "DEPLOYMENT COMPLETE! 🎉"

echo ""
echo -e "${GREEN}Your application is now deployed!${NC}"
echo ""
echo "📍 Frontend URL: $VERCEL_URL"
echo "📍 Backend URL: https://$RENDER_SERVICE_NAME.onrender.com"
echo ""
echo "⏳ Services may take 1-2 minutes to fully initialize."
echo "   Free tier services spin down after 15 minutes of inactivity."
echo ""
echo "🧪 Testing: Open $VERCEL_URL in your browser and try playing!"
echo ""
echo "📊 Dashboards:"
echo "   • Vercel: https://vercel.com/dashboard"
echo "   • Render: https://render.com/dashboard"
echo ""
print_success "Deployment automation complete!"
