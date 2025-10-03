@echo off
echo 🌶️ Spice E-commerce - Login Debug Script
echo ==========================================
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js not found! Please install Node.js first.
    pause
    exit /b 1
)

REM Check if .env file exists
if not exist .env (
    echo ❌ .env file not found! Creating default .env file...
    copy .env.local .env >nul 2>&1
    echo ✅ Default .env file created
    echo.
)

REM Kill any existing processes on port 3001
echo 🔍 Checking for existing processes on port 3001...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3001 ^| findstr LISTENING') do (
    echo 🛑 Killing process %%a on port 3001...
    taskkill /F /PID %%a >nul 2>&1
)

REM Start the backend server in background
echo 🚀 Starting backend server...
start /B node index.js

REM Wait for server to start
echo ⏳ Waiting for server to start...
timeout /t 3 >nul

REM Test the login functionality
echo 🧪 Testing login functionality...
echo.
node test-login.js

echo.
echo 🏁 Debug completed!
echo.
echo 💡 Tips for troubleshooting:
echo - Make sure MySQL is running in Laragon
echo - Check if database 'spice_ecommerce' exists
echo - Verify .env file has correct DATABASE_URL and JWT_SECRET
echo - Run 'npm run prisma:seed' if no users exist
echo.
pause
