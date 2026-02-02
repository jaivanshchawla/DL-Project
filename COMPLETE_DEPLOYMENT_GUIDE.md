# Complete End-to-End Deployment Guide

Deploy your entire Connect Four AI application (Frontend + Backend + Optional ML Service) in minutes!

---

## 🎯 Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                   │
│  Your Domain (Optional)  →  Vercel (Frontend)                   │
│                              ↓                                    │
│                              ↓ (API calls)                       │
│                         Render (Backend NestJS)                  │
│                              ↓                                    │
│                              ↓ (Optional ML calls)               │
│                         Render (ML Service)                      │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Services Overview:
- **Frontend (React)** → Vercel (free tier - most popular choice)
- **Backend (NestJS)** → Render.com (free tier available)
- **ML Service (Python)** → Optional, can be disabled

---

## 📋 Prerequisites

Before you start, you need:

- ✅ **GitHub Account** (to push your code)
- ✅ **Vercel Account** (free at vercel.com)
- ✅ **Render Account** (free at render.com)
- ✅ **Your own domain** (optional, for custom domain)
- ✅ Git installed locally

### Why These Platforms?
| Platform | Why | Free Tier? |
|----------|-----|----------|
| **Vercel** | Built for React/Next.js, excellent performance | ✅ Yes |
| **Render** | Best for Node.js backends, WebSocket support | ✅ Yes |
| Alternative: Railway.app | Also excellent, similar to Render | ✅ Yes |
| Alternative: Fly.io | Good for Python, Docker support | ✅ Yes |

---

## 🚀 Step-by-Step Deployment

### **STEP 1: Prepare Your Local Repository**

#### 1.1 Initialize Git (if not already done)
```bash
cd your-project-folder
git init
git add .
git commit -m "Initial commit - ready for deployment"
```

#### 1.2 Create `.gitignore` (if missing)
Make sure you have a proper `.gitignore`:
```bash
# Node modules
node_modules/
npm-debug.log
yarn-error.log

# Build artifacts
build/
dist/
.next/

# Environment files (NEVER commit these!)
.env
.env.local
.env.*.local

# OS files
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# ML Service
ml_service/.venv
ml_service/__pycache__
ml_service/*.pyc
```

#### 1.3 Push to GitHub
```bash
git remote add origin https://github.com/YOUR_USERNAME/Connect-Four-AI.git
git branch -M main
git push -u origin main
```

✅ **Done!** Your code is now on GitHub.

---

### **STEP 2: Deploy Frontend to Vercel** (5 minutes)

#### 2.1 Create Vercel Project
1. Go to [vercel.com](https://vercel.com)
2. Click **"Add New"** → **"Project"**
3. Click **"Import Git Repository"**
4. Select your GitHub repo `Connect-Four-AI`
5. Click **"Import"**

#### 2.2 Configure Vercel Settings

**Root Directory**: Set to `frontend` (THIS IS IMPORTANT!)

**Environment Variables**: Add these (exact names matter!)

```
REACT_APP_API_URL = https://your-backend-url.onrender.com
REACT_APP_WS_URL = wss://your-backend-url.onrender.com
REACT_APP_ENVIRONMENT = production
REACT_APP_AI_EXPLANATIONS = false
REACT_APP_AI_RECOMMENDATIONS = false
REACT_APP_ENTERPRISE_MODE = false
REACT_APP_FAST_AI_MODE = true
```

**Note**: You'll update `REACT_APP_API_URL` after backend is deployed (Step 3).

#### 2.3 Deploy
Click **"Deploy"** and wait ~2-3 minutes.

✅ **Your frontend is live!** You'll get a URL like: `https://connect-four-ai.vercel.app`

**Save this URL** - you'll need it for the backend.

---

### **STEP 3: Deploy Backend to Render** (5 minutes)

#### 3.1 Create Render Account & Service

1. Go to [render.com](https://render.com)
2. Click **"New+"** → **"Web Service"**
3. Click **"Build and deploy from a Git repository"**
4. Connect GitHub and select your repo

#### 3.2 Configure Render Settings

Fill in these fields:

| Field | Value |
|-------|-------|
| **Name** | `connect-four-backend` |
| **Environment** | `Node` |
| **Region** | Choose closest to you |
| **Branch** | `main` |
| **Build Command** | `cd backend && npm install && npm run build` |
| **Start Command** | `cd backend && npm run start:prod` |
| **Root Directory** | Leave empty |

#### 3.3 Add Environment Variables

In Render Dashboard → Your Service → **Environment**:

```
NODE_ENV = production
PORT = 10000
CORS_ORIGIN = https://your-frontend.vercel.app
DISABLE_EXTERNAL_SERVICES = true
AI_DIFFICULTY_MIN = 1
AI_DIFFICULTY_MAX = 30
AI_THINKING_TIME_MAX = 30000
AI_CACHE_SIZE = 100000
FAST_MODE = true
SKIP_ML_INIT = true
REACT_APP_API_URL = https://your-backend-url.onrender.com
```

⚠️ **IMPORTANT**: Replace `https://your-frontend.vercel.app` with your actual Vercel URL!

#### 3.4 Deploy

Click **"Create Web Service"** and wait 3-5 minutes.

When done, you'll get a URL like: `https://connect-four-backend.onrender.com`

**Save this URL**!

✅ **Backend is live!**

---

### **STEP 4: Update Frontend Environment Variables**

Now that you have the backend URL, update Vercel:

1. Go to [vercel.com](https://vercel.com) → Your Project
2. Click **"Settings"** → **"Environment Variables"**
3. Update `REACT_APP_API_URL` to your backend URL:
   ```
   REACT_APP_API_URL = https://connect-four-backend.onrender.com
   REACT_APP_WS_URL = wss://connect-four-backend.onrender.com
   ```
4. **Redeploy**: Go to **"Deployments"** → **"..."** → **"Redeploy"** on latest

Wait 1-2 minutes for redeploy.

✅ **Everything is connected!**

---

### **STEP 5: (Optional) Deploy ML Service**

If you want advanced AI features, deploy the Python ML service:

#### 5.1 Create Another Render Service

1. In Render Dashboard: Click **"New+"** → **"Web Service"**
2. Connect same GitHub repo

#### 5.2 Configure

| Field | Value |
|-------|-------|
| **Name** | `connect-four-ml` |
| **Environment** | `Python 3` |
| **Build Command** | `cd ml_service && pip install -r requirements.txt` |
| **Start Command** | `cd ml_service && gunicorn -w 1 -b 0.0.0.0:$PORT ml_service:app` |
| **Root Directory** | Leave empty |

#### 5.3 Environment Variables

```
PYTHON_VERSION = 3.9
PORT = 10000
```

#### 5.4 Deploy & Update Backend

Once deployed, get the ML service URL and update backend environment:

Add in Render backend service:
```
ML_SERVICE_URL = https://connect-four-ml.onrender.com
ENABLE_ML_SERVICE = true
DISABLE_EXTERNAL_SERVICES = false
```

Then:
- Update frontend env vars to enable AI features:
```
REACT_APP_AI_EXPLANATIONS = true
REACT_APP_AI_RECOMMENDATIONS = true
REACT_APP_ENTERPRISE_MODE = true
```

---

## 🔗 Testing Your Deployment

After all steps are complete:

1. **Open your frontend URL** in browser (from Vercel)
2. You should see the game load
3. **Try playing a game** - this tests the backend connection
4. **Check browser console** (F12) for any errors

### Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| **CORS error** | Make sure `CORS_ORIGIN` in Render matches your Vercel URL exactly (with `https://`) |
| **Blank page** | Check browser console (F12), look for API errors. Verify environment variables. |
| **Game doesn't load** | Backend might still be spinning up (can take 30 secs on free tier) |
| **API calls fail** | Verify `REACT_APP_API_URL` is correct in Vercel environment |

---

## 📊 Cost Summary (Free Tier)

| Service | Free Tier | Limits |
|---------|-----------|--------|
| **Vercel** | ✅ Unlimited | 100 GB bandwidth/month |
| **Render** | ✅ Available | 750 free hours/month |
| **Render Web Service** | ✅ Available | Spins down after 15 min inactivity |
| **Total Monthly Cost** | **$0** | Perfect for portfolio showcase |

**Pro Tip**: To keep services awake, Render allows keeping one free service always on. Use a monitoring tool like [UptimeRobot](https://uptimerobot.com) (free) to ping your backend every 5 minutes.

---

## 🎨 Optional: Custom Domain Setup

If you want to use your own domain (e.g., `connect-four.yourdomain.com`):

### For Frontend (Vercel)
1. Vercel Dashboard → Settings → Domains
2. Add your domain
3. Follow DNS configuration steps

### For Backend (Render)
1. Render Dashboard → Service Settings → Custom Domain
2. Add your domain
3. Follow DNS configuration steps

---

## 📚 Project Structure for Deployment

Your repo should look like this:

```
Connect-Four-AI/
├── frontend/                  # React app (Vercel deploys this)
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── vercel.json
├── backend/                   # NestJS app (Render deploys this)
│   ├── src/
│   ├── package.json
│   └── tsconfig.json
├── ml_service/                # Python ML (Optional)
│   ├── ml_service.py
│   ├── requirements.txt
│   └── ...
├── .gitignore
├── README.md
└── COMPLETE_DEPLOYMENT_GUIDE.md (this file)
```

---

## 🔒 Security Considerations

### Before Deploying:

1. **Never commit `.env` files** ✅ (use `.gitignore`)
2. **Use strong JWT secret** in backend (set in Render env vars)
3. **Enable CORS** only for your frontend domain
4. **Use HTTPS everywhere** (Vercel/Render do this automatically)
5. **Disable debug mode** in production (already set in config)

---

## 📞 Troubleshooting Checklists

### "Frontend loads but says 'Cannot connect to API'"
- [ ] Backend URL in `REACT_APP_API_URL` is correct?
- [ ] Backend service is running (check Render dashboard)?
- [ ] CORS_ORIGIN in backend matches frontend URL?
- [ ] Waited 2+ minutes for service to start?

### "Backend won't deploy"
- [ ] Check Render logs for errors
- [ ] Verify `build` command completes without errors
- [ ] Check Node.js version compatibility (needs 18+)
- [ ] Try clearing Render's build cache and redeploy

### "CORS errors in console"
- [ ] Ensure no trailing slash in URLs
- [ ] Make sure CORS_ORIGIN uses `https://` in production
- [ ] Clear browser cache and hard refresh (Ctrl+Shift+R)

### "WebSocket connection failed"
- [ ] Use `wss://` not `ws://` in production
- [ ] Verify both frontend and backend are running
- [ ] Check that URL doesn't have protocol prefix twice

---

## 🎉 Success Checklist

- [ ] GitHub repo created and code pushed
- [ ] Frontend deployed to Vercel
- [ ] Backend deployed to Render
- [ ] Environment variables set on both platforms
- [ ] Frontend and backend can communicate
- [ ] Game loads and plays correctly
- [ ] No console errors when playing
- [ ] (Optional) ML service deployed
- [ ] (Optional) Custom domain configured

---

## 📖 Quick Reference URLs

After deployment, you'll have:

```
Frontend: https://your-project.vercel.app
Backend API: https://your-backend.onrender.com
Backend WebSocket: wss://your-backend.onrender.com
```

Use these URLs in:
- Browser to access the app
- Environment variables in other services
- Custom domain DNS configuration

---

## 🆘 Getting Help

If something goes wrong:

1. **Check the logs**:
   - Vercel: Deployments tab → click deployment → Logs
   - Render: Service dashboard → Logs

2. **Common errors**:
   - `Build failed`: Check that the build command matches your setup
   - `Connection refused`: Backend might not be running yet
   - `Port already in use`: Different port issue (shouldn't happen on Vercel/Render)

3. **Verify configurations**:
   - Run locally first: `npm run start:all`
   - Make sure everything works before deploying

---

## 🚀 Next Steps

Once deployed:

1. **Share the link** with friends/colleagues
2. **Monitor the services** via dashboards
3. **Keep dependencies updated** locally and redeploy
4. **Set up analytics** (Vercel has built-in)
5. **Consider upgrading** if you need more power/reliability

---

**Last Updated**: January 18, 2026
**Project**: Connect Four AI
**All services deployed**: ✅ Frontend + Backend + Optional ML Service
