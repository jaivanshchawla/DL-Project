# Quick Start Guide

Get up and running in 5 minutes!

## Prerequisites Check

Make sure you have:
- ✅ Node.js 18+ installed (`node --version`)
- ✅ npm installed (`npm --version`)
- ✅ Python 3.9+ (optional, for ML service)

## Windows Setup

Run the setup script:
```powershell
.\setup.ps1
```

Or manually:
```powershell
npm install
cd frontend && npm install && cd ..
cd backend && npm install && cd ..
```

## Mac/Linux Setup

Run the setup script:
```bash
chmod +x setup.sh
./setup.sh
```

Or manually:
```bash
npm install
cd frontend && npm install && cd ..
cd backend && npm install && cd ..
```

## Start Development

### Option 1: Start Everything (Recommended)
```bash
npm run start:all
```

### Option 2: Start Individually

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

## Access the App

- Frontend: http://localhost:3001
- Backend API: http://localhost:3000

## Deploy to Vercel

1. Push to GitHub
2. Import to Vercel
3. Set Root Directory to `frontend`
4. Add environment variables (see DEPLOYMENT.md)
5. Deploy!

## Need Help?

- See `SETUP.md` for detailed setup
- See `DEPLOYMENT.md` for deployment guide
- Check `README.md` for full documentation

Happy coding! 🎮
