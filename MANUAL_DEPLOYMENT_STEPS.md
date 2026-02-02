# Quick Manual Deployment Steps

Follow these simple steps to deploy your Connect Four AI to Vercel and Render.

## Step 1: Install Vercel CLI
```powershell
npm install -g vercel
```

## Step 2: Deploy Frontend to Vercel

```powershell
cd frontend
vercel --prod
```

**When prompted:**
- Scope: Select your account
- Project name: `connect-four-ai-frontend` (or any name)
- Framework: React
- Build: `npm run build`
- Output directory: `build`

**Save the Vercel URL** - you'll need it for the backend!

## Step 3: Configure Backend Environment Variables

Create `.env` file in backend folder:

```
NODE_ENV=production
CORS_ORIGIN=https://YOUR_VERCEL_URL.vercel.app
DISABLE_EXTERNAL_SERVICES=true
FAST_MODE=true
PORT=3001
```

Replace `YOUR_VERCEL_URL` with the URL from Step 2.

## Step 4: Deploy Backend to Render

1. Go to https://render.com
2. Click "New +"
3. Select "Web Service"
4. Connect your GitHub repository (jaivanshchawla/DL-Project)
5. Fill in:
   - **Name:** `connect-four-ai-backend`
   - **Root Directory:** `backend`
   - **Build Command:** `npm install && npm run build`
   - **Start Command:** `npm run start:prod`
   - **Instance Type:** Free
6. Click "Create Web Service"

## Step 5: Add Environment Variables on Render

In Render dashboard for your backend service:
1. Go to "Environment"
2. Add these variables:
   - `NODE_ENV`: `production`
   - `CORS_ORIGIN`: `https://YOUR_VERCEL_URL.vercel.app`
   - `DISABLE_EXTERNAL_SERVICES`: `true`
   - `FAST_MODE`: `true`
   - `PORT`: `3001`

## Step 6: Update Frontend Environment Variables on Vercel

1. Go to https://vercel.com/dashboard
2. Select your `connect-four-ai-frontend` project
3. Go to "Settings" → "Environment Variables"
4. Add:
   - `REACT_APP_API_URL`: `https://YOUR_RENDER_URL.onrender.com`
   - `REACT_APP_WS_URL`: `wss://YOUR_RENDER_URL.onrender.com`
   - `REACT_APP_ENVIRONMENT`: `production`

(Get your Render URL from the backend service page on Render dashboard)

## Step 7: Redeploy Frontend

Go back to Vercel, click "Redeploy" to pick up the new environment variables.

## Step 8: Test

1. Open your Vercel URL in browser
2. Try playing a game
3. Check browser console (F12) for any errors

## Done!

Your Connect Four AI is now live on:
- **Frontend:** `https://YOUR_VERCEL_URL.vercel.app`
- **Backend:** `https://YOUR_RENDER_URL.onrender.com`

---

## Troubleshooting

### Backend not responding?
- Check Render dashboard for build/deployment errors
- Make sure CORS_ORIGIN environment variable is set correctly
- Render free tier sleeps after 15 min - it will wake on next request

### UI not loading?
- Check that REACT_APP_API_URL is set correctly
- Open browser console (F12) for specific errors

### Game not working?
- Check Network tab in browser DevTools for failed requests
- Make sure both services have been deployed and are running
