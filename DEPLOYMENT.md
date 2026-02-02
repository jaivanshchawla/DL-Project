# Deployment Guide - Connect Four AI

This guide covers deploying the Connect Four AI application to Vercel and other services.

## Architecture Overview

This project consists of three main components:
1. **Frontend** (React) - Deploy to Vercel
2. **Backend** (NestJS) - Deploy to Render/Railway/Heroku
3. **ML Service** (Python/FastAPI) - Optional, deploy separately

## Vercel Deployment (Frontend)

### Prerequisites
- GitHub account
- Vercel account (free tier available)

### Step 1: Prepare Your Repository

1. Make sure your code is pushed to GitHub:
```bash
git add .
git commit -m "Ready for deployment"
git push origin main
```

### Step 2: Deploy via Vercel Dashboard

1. Go to [vercel.com](https://vercel.com) and sign in
2. Click "Add New Project"
3. Import your GitHub repository
4. Configure the project:
   - **Framework Preset**: Create React App
   - **Root Directory**: `frontend`
   - **Build Command**: `npm run build`
   - **Output Directory**: `build`
   - **Install Command**: `npm install`

### Step 3: Configure Environment Variables

In Vercel Dashboard → Project Settings → Environment Variables, add:

```
REACT_APP_API_URL=https://your-backend-url.onrender.com
REACT_APP_WS_URL=wss://your-backend-url.onrender.com
REACT_APP_ML_SERVICE_URL=https://your-ml-service-url.onrender.com
REACT_APP_ENVIRONMENT=production
REACT_APP_ANALYTICS_ENABLED=true
```

**Important**: Replace `your-backend-url` with your actual backend deployment URL.

### Step 4: Deploy

Click "Deploy" and wait for the build to complete. Your frontend will be live at `https://your-project.vercel.app`

## Backend Deployment (Render.com)

### Step 1: Create Render Account

1. Go to [render.com](https://render.com) and sign up
2. Connect your GitHub account

### Step 2: Create Web Service

1. Click "New +" → "Web Service"
2. Connect your repository
3. Configure:
   - **Name**: `connect-four-backend`
   - **Environment**: `Node`
   - **Build Command**: `cd backend && npm install && npm run build`
   - **Start Command**: `cd backend && npm run start:prod`
   - **Root Directory**: Leave empty (or set to project root)

### Step 3: Environment Variables

Add these in Render Dashboard → Environment:

```
NODE_ENV=production
PORT=10000
CORS_ORIGIN=https://your-frontend.vercel.app
AI_DIFFICULTY_MIN=1
AI_DIFFICULTY_MAX=30
AI_THINKING_TIME_MAX=30000
AI_CACHE_SIZE=100000
ML_SERVICE_URL=https://your-ml-service.onrender.com
```

### Step 4: Deploy

Click "Create Web Service" and wait for deployment.

### Step 5: Update Frontend Environment Variables

After backend is deployed, update your Vercel environment variables with the new backend URL.

## ML Service Deployment (Optional)

### Deploy to Render

1. Create a new Web Service on Render
2. Configure:
   - **Environment**: `Python 3`
   - **Build Command**: `cd ml_service && pip install -r requirements.txt`
   - **Start Command**: `cd ml_service && python ml_service.py`
   - **Root Directory**: Leave empty

3. Add environment variables:
```
PYTHON_VERSION=3.9
PORT=8000
```

## Alternative Deployment Options

### Railway.app

Railway is another excellent option for deploying both backend and ML service:

1. Go to [railway.app](https://railway.app)
2. Create new project from GitHub
3. Add services for backend and ML service
4. Configure environment variables
5. Deploy

### Heroku

1. Install Heroku CLI
2. Create apps:
```bash
heroku create connect-four-backend
heroku create connect-four-ml-service
```

3. Deploy:
```bash
cd backend
git subtree push --prefix backend heroku main

cd ../ml_service
git subtree push --prefix ml_service heroku main
```

## Environment Variables Summary

### Frontend (Vercel)
- `REACT_APP_API_URL` - Backend API URL
- `REACT_APP_WS_URL` - WebSocket URL (use `wss://` for production)
- `REACT_APP_ML_SERVICE_URL` - ML service URL
- `REACT_APP_ENVIRONMENT` - Set to `production`

### Backend (Render/Railway)
- `NODE_ENV` - Set to `production`
- `PORT` - Usually auto-assigned (10000 for Render)
- `CORS_ORIGIN` - Your Vercel frontend URL
- `ML_SERVICE_URL` - ML service URL (if deployed)

### ML Service (Render/Railway)
- `PORT` - Usually auto-assigned
- `PYTHON_VERSION` - Python version (3.9+)

## Post-Deployment Checklist

- [ ] Frontend deployed to Vercel
- [ ] Backend deployed to Render/Railway
- [ ] Environment variables configured in all services
- [ ] CORS configured correctly
- [ ] WebSocket connections working (check for `wss://` in production)
- [ ] Test the application end-to-end
- [ ] Monitor logs for errors
- [ ] Set up custom domain (optional)

## Troubleshooting

### CORS Errors

If you see CORS errors:
1. Check `CORS_ORIGIN` in backend environment variables
2. Make sure it matches your frontend URL exactly
3. For Vercel, use the full URL: `https://your-project.vercel.app`

### WebSocket Connection Failed

1. Make sure you're using `wss://` (secure WebSocket) in production
2. Check that the backend WebSocket server is running
3. Verify the WebSocket URL in frontend environment variables

### Build Failures

1. Check build logs in Vercel/Render dashboard
2. Ensure all dependencies are in `package.json`
3. Verify Node.js version compatibility
4. Check for TypeScript errors

### Environment Variables Not Working

1. Environment variables must be set in the deployment platform
2. For Vercel, variables starting with `REACT_APP_` are automatically injected
3. Restart the service after adding new variables
4. Clear build cache if variables still don't work

## Continuous Deployment

Both Vercel and Render support automatic deployments:
- **Vercel**: Automatically deploys on every push to main branch
- **Render**: Can be configured for auto-deploy in settings

## Monitoring

### Vercel Analytics
- Built-in analytics available in Vercel dashboard
- Enable Speed Insights for performance monitoring

### Render Logs
- View real-time logs in Render dashboard
- Set up alerts for errors

## Cost Estimates

### Free Tier
- **Vercel**: Free for personal projects
- **Render**: Free tier with limitations (spins down after inactivity)
- **Railway**: $5/month with $5 credit

### Paid Options
- **Vercel Pro**: $20/month
- **Render**: $7/month per service
- **Railway**: Pay-as-you-go

## Next Steps

1. Set up custom domain
2. Configure SSL certificates (automatic on Vercel/Render)
3. Set up monitoring and alerts
4. Configure CI/CD pipelines
5. Set up staging environment

## Support

For deployment issues:
1. Check service logs
2. Review environment variable configuration
3. Verify all services are running
4. Test API endpoints directly

Happy deploying! 🚀
