@echo off
title Create Placeholder Icons for Spice Ecommerce

echo ========================================
echo   CREATING PLACEHOLDER ICONS
echo ========================================

echo.
echo Creating web\icons directory...
if not exist "web\icons" mkdir web\icons

echo.
echo Creating placeholder icon files...

echo [1/4] Creating Icon-192.png placeholder...
echo. > web\icons\Icon-192.png

echo [2/4] Creating Icon-512.png placeholder...
echo. > web\icons\Icon-512.png

echo [3/4] Creating Icon-maskable-192.png placeholder...
echo. > web\icons\Icon-maskable-192.png

echo [4/4] Creating Icon-maskable-512.png placeholder...
echo. > web\icons\Icon-maskable-512.png

echo.
echo ========================================
echo  ✅ PLACEHOLDER ICONS CREATED!
echo ========================================
echo.
echo Note: These are placeholder files.
echo For production, replace with actual PNG icons:
echo  - web\icons\Icon-192.png (192x192 pixels)
echo  - web\icons\Icon-512.png (512x512 pixels)
echo  - web\icons\Icon-maskable-192.png (192x192 pixels)
echo  - web\icons\Icon-maskable-512.png (512x512 pixels)
echo.
echo You can create icons at:
echo  - https://favicon.io/
echo  - https://realfavicongenerator.net/
echo  - Canva.com
echo.
pause
