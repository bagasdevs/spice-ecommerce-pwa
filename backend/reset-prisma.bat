@echo off
title Reset Prisma Database - Spice Ecommerce

echo ========================================
echo   PRISMA DATABASE RESET SCRIPT
echo ========================================

echo.
echo [1/8] Stopping all Node.js processes...
tasklist /FI "IMAGENAME eq node.exe" 2>NUL | find /I /N "node.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Found Node.js processes, stopping...
    taskkill /F /IM node.exe /T 2>nul
    timeout /t 3
) else (
    echo No Node.js processes found
)

echo.
echo [2/8] Stopping Prisma Studio processes...
taskkill /F /FI "WINDOWTITLE:*Prisma*" /T 2>nul
timeout /t 2

echo.
echo [3/8] Cleaning Prisma client files...
if exist "node_modules\.prisma" (
    echo Removing .prisma directory...
    rmdir /S /Q "node_modules\.prisma" 2>nul
)

if exist "prisma\migrations" (
    echo Removing migrations directory...
    rmdir /S /Q "prisma\migrations" 2>nul
)

echo.
echo [4/8] Backing up current schema...
if exist "prisma\schema.prisma" (
    copy "prisma\schema.prisma" "prisma\schema.backup.prisma" >nul
    echo Schema backed up to schema.backup.prisma
)

echo.
echo [5/8] Resetting MySQL database...
echo Connecting to MySQL...

mysql -u root -p123 -e "DROP DATABASE IF EXISTS spice_ecommerce;" 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Database dropped successfully
) else (
    echo Warning: Could not drop database (might not exist)
)

mysql -u root -p123 -e "CREATE DATABASE spice_ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Database created successfully
) else (
    echo Error: Could not create database
    echo Please check MySQL connection or create database manually:
    echo   - Open phpMyAdmin: http://localhost/phpmyadmin
    echo   - Login: root / 123
    echo   - Create database: spice_ecommerce
    pause
    exit /b 1
)

echo.
echo [6/8] Reinstalling Node.js dependencies...
echo This may take a few minutes...
npm install --silent
if %ERRORLEVEL% NEQ 0 (
    echo Error: npm install failed
    pause
    exit /b 1
)

echo.
echo [7/8] Generating fresh Prisma client...
npx prisma generate
if %ERRORLEVEL% NEQ 0 (
    echo Error: Prisma generate failed
    pause
    exit /b 1
)

echo.
echo [8/8] Pushing schema to database...
npx prisma db push --force-reset
if %ERRORLEVEL% NEQ 0 (
    echo Error: Prisma db push failed
    echo Trying alternative method...
    npx prisma db push --skip-generate
)

echo.
echo ========================================
echo  ✅ PRISMA RESET COMPLETED!
echo ========================================
echo.
echo Next steps:
echo  1. Verify database: npx prisma studio
echo  2. Start backend: npm run dev
echo  3. Check tables in phpMyAdmin: http://localhost/phpmyadmin
echo.
echo Database Details:
echo  - Host: localhost:3306
echo  - Database: spice_ecommerce
echo  - User: root
echo  - Password: 123
echo.

set /p answer="Do you want to open Prisma Studio now? (y/N): "
if /i "%answer:~0,1%" EQU "Y" (
    echo Opening Prisma Studio...
    start "Prisma Studio" cmd /k "npx prisma studio"
    timeout /t 3
    start http://localhost:5555
)

echo.
echo ========================================
echo  🎉 RESET COMPLETE - READY FOR DEVELOPMENT!
echo ========================================
pause
