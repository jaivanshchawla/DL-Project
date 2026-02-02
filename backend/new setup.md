# Setup Guide for Connect Four AI

This guide will help you set up the project for local development and Vercel deployment.

## Prerequisites

Before you begin, make sure you have the following installed:

- **Node.js** (v18.0.0 or higher) - [Download](https://nodejs.org/)
- **npm** (comes with Node.js)
- **Python 3.9+** (for ML service) - [Download](https://www.python.org/downloads/)
- **Git** - [Download](https://git-scm.com/downloads)

## Local Development Setup

### 1. Install Dependencies

Run these commands in order:

```bash
# Install root dependencies
npm install

# Install frontend dependencies
cd frontend
npm install
cd ..

# Install backend dependencies
cd backend
npm install
cd ..

# Install ML service dependencies (Python)
cd ml_service
pip install -r requirements.txt
cd ..
```

### 2. Configure Environment Variables

#### Frontend Configuration

Copy the example environment file and customize it:

```bash
cd frontend
copy .env.example .env.local
```

Edit `frontend/.env.local` with your local settings:
- `REACT_APP_API_URL` - Backend API URL (default: http://localhost:3000)
- `REACT_APP_WS_URL` - WebSocket URL (default: ws://localhost:3000)
- `REACT_APP_ML_SERVICE_URL` - ML service URL (default: http://localhost:8000)

#### Backend Configuration

```bash
cd backend
copy .env.example .env
```

Edit `backend/.env` with your settings. The defaults should work for local development.

### 3. Start the Development Servers

You have several options:

#### Option A: Start All Services (Recommended)
```bash
# From the root directory
npm run start:all
```

#### Option B: Start Services Individually

**Terminal 1 - Backend:**
```bash
cd backend
npm run start:dev
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm start
```

**Terminal 3 - ML Service (Optional):**
```bash
cd ml_service
npm start
```

### 4. Access the Application

- **Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3000
- **ML Service**: http://localhost:8000 (if running)

## Vercel Deployment Setup

### 1. Prepare for Deployment

The project is already configured for Vercel deployment. The `frontend/vercel.json` file contains the deployment configuration.

### 2. Deploy to Vercel

#### Option A: Deploy via Vercel CLI

1. Install Vercel CLI:
```bash
npm install -g vercel
```

2. Login to Vercel:
```bash
vercel login
```

3. Deploy from the frontend directory:
```bash
cd frontend
vercel
```

4. Follow the prompts to configure your deployment.

#### Option B: Deploy via GitHub Integration

1. Push your code to GitHub:
```bash
git add .
git commit -m "Setup for Vercel deployment"
git push origin main
```

2. Go to [Vercel Dashboard](https://vercel.com/dashboard)

3. Click "New Project"

4. Import your GitHub repository

5. Configure the project:
   - **Framework Preset**: Create React App
   - **Root Directory**: `frontend`
   - **Build Command**: `npm run build`
   - **Output Directory**: `build`
   - **Install Command**: `npm install`

6. Add Environment Variables in Vercel Dashboard:
   - Go to Project Settings → Environment Variables
   - Add the following variables:
     ```
     REACT_APP_API_URL=https://your-backend-url.com
     REACT_APP_WS_URL=wss://your-backend-url.com
     REACT_APP_ML_SERVICE_URL=https://your-ml-service-url.com
     REACT_APP_ENVIRONMENT=production
     ```

7. Click "Deploy"

### 3. Backend Deployment (Separate Service)

**Important**: Vercel is primarily for frontend/static sites. For the backend, you'll need to deploy to a different service:

#### Recommended Options:
- **Render.com** - Free tier available, good for Node.js apps
- **Railway.app** - Easy deployment, good developer experience
- **Heroku** - Traditional option (paid plans)
- **AWS/Google Cloud/Azure** - For production scale

#### Example: Deploy Backend to Render

1. Create a new Web Service on Render
2. Connect your GitHub repository
3. Configure:
   - **Build Command**: `cd backend && npm install && npm run build`
   - **Start Command**: `cd backend && npm run start:prod`
   - **Environment**: Node
4. Add environment variables from `backend/.env.example`
5. Deploy

### 4. Update Frontend Environment Variables

After deploying the backend, update your Vercel environment variables with the actual backend URL.

## Troubleshooting

### Port Already in Use

If you get "port already in use" errors:

**Windows:**
```bash
# Find process using port 3000
netstat -ano | findstr :3000
# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

**Mac/Linux:**
```bash
# Find and kill process on port 3000
lsof -ti:3000 | xargs kill -9
```

### Dependencies Installation Issues

If you encounter issues installing dependencies:

```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Python/ML Service Issues

If ML service fails to start:

```bash
# Check Python version (should be 3.9+)
python --version

# Create virtual environment (recommended)
cd ml_service
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Build Errors

If you get build errors:

1. Make sure all dependencies are installed
2. Check Node.js version: `node --version` (should be 18+)
3. Clear build cache:
```bash
cd frontend
rm -rf build node_modules
npm install
npm run build
```

## Quick Start Commands

```bash
# Start everything
npm run start:all

# Start only frontend and backend (faster)
npm run start:all:fast

# Stop all services
npm run stop:all

# Check system health
npm run health:check

# Development mode
npm run dev
```

## Environment Variables Reference

### Frontend (.env.local)
- `REACT_APP_API_URL` - Backend API base URL
- `REACT_APP_WS_URL` - WebSocket URL
- `REACT_APP_ML_SERVICE_URL` - ML service URL
- `REACT_APP_ENVIRONMENT` - Environment (development/production)
- `REACT_APP_DEBUG_MODE` - Enable debug logging
- `REACT_APP_ANALYTICS_ENABLED` - Enable analytics

### Backend (.env)
- `NODE_ENV` - Node environment
- `PORT` - Backend server port
- `CORS_ORIGIN` - Allowed CORS origin
- `AI_DIFFICULTY_MIN/MAX` - AI difficulty range
- `ML_SERVICE_URL` - ML service URL

## Next Steps

1. ✅ Install all dependencies
2. ✅ Configure environment variables
3. ✅ Start development servers
4. ✅ Test locally
5. ✅ Deploy to Vercel
6. ✅ Deploy backend to separate service
7. ✅ Update environment variables in Vercel

## Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Review the main README.md
3. Check service logs for error messages
4. Ensure all prerequisites are installed correctly

Happy coding! 🚀
