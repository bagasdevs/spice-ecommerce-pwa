@echo off
title Create Simple Icons for Spice Ecommerce

echo ========================================
echo   CREATING SIMPLE ICONS
echo ========================================

echo.
echo Creating web\icons directory...
if not exist "web\icons" mkdir web\icons

echo.
echo Using Flutter default icons...

:: Check if Flutter default icons exist
set "flutter_path=%LOCALAPPDATA%\Pub\Cache\hosted\pub.dartlang.org"
set "flutter_icons_path=%flutter_path%\flutter-*\packages\flutter\lib\src\material\icons"

:: Create simple colored squares as placeholder icons
echo Creating colored placeholder icons...

:: Create 192x192 icon using PowerShell
echo [1/4] Creating Icon-192.png...
powershell -Command "Add-Type -AssemblyName System.Drawing; $bitmap = New-Object System.Drawing.Bitmap(192, 192); $graphics = [System.Drawing.Graphics]::FromImage($bitmap); $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(76, 175, 80)); $graphics.FillRectangle($brush, 0, 0, 192, 192); $font = New-Object System.Drawing.Font('Arial', 24, [System.Drawing.FontStyle]::Bold); $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White); $graphics.DrawString('S', $font, $textBrush, 80, 80); $bitmap.Save('web\icons\Icon-192.png', [System.Drawing.Imaging.ImageFormat]::Png); $graphics.Dispose(); $bitmap.Dispose()"

:: Create 512x512 icon
echo [2/4] Creating Icon-512.png...
powershell -Command "Add-Type -AssemblyName System.Drawing; $bitmap = New-Object System.Drawing.Bitmap(512, 512); $graphics = [System.Drawing.Graphics]::FromImage($bitmap); $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(76, 175, 80)); $graphics.FillRectangle($brush, 0, 0, 512, 512); $font = New-Object System.Drawing.Font('Arial', 64, [System.Drawing.FontStyle]::Bold); $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White); $graphics.DrawString('S', $font, $textBrush, 220, 220); $bitmap.Save('web\icons\Icon-512.png', [System.Drawing.Imaging.ImageFormat]::Png); $graphics.Dispose(); $bitmap.Dispose()"

:: Copy to maskable versions
echo [3/4] Creating Icon-maskable-192.png...
copy "web\icons\Icon-192.png" "web\icons\Icon-maskable-192.png" >nul

echo [4/4] Creating Icon-maskable-512.png...
copy "web\icons\Icon-512.png" "web\icons\Icon-maskable-512.png" >nul

echo.
echo ========================================
echo  ✅ SIMPLE ICONS CREATED!
echo ========================================
echo.
echo Created icons:
echo  - web\icons\Icon-192.png (192x192 green square with 'S')
echo  - web\icons\Icon-512.png (512x512 green square with 'S')
echo  - web\icons\Icon-maskable-192.png (copy of 192px)
echo  - web\icons\Icon-maskable-512.png (copy of 512px)
echo.
echo Note: These are simple placeholder icons.
echo For production, create proper app icons with your logo.
echo.
pause
