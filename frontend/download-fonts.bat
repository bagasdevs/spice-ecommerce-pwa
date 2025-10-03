@echo off
title Download Google Fonts for Spice Ecommerce

echo ========================================
echo   DOWNLOADING GOOGLE FONTS
echo ========================================

echo.
echo Creating fonts directory...
if not exist "assets\fonts" mkdir assets\fonts

echo.
echo Downloading Poppins fonts from Google Fonts...

:: Download Poppins Regular
echo [1/6] Downloading Poppins-Regular.ttf...
powershell -Command "Invoke-WebRequest -Uri 'https://fonts.gstatic.com/s/poppins/v20/pxiEyp8kv8JHgFVrBIZXZ1tjEw.ttf' -OutFile 'assets\fonts\Poppins-Regular.ttf'"

:: Download Poppins Medium
echo [2/6] Downloading Poppins-Medium.ttf...
powershell -Command "Invoke-WebRequest -Uri 'https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLEj6Z1xlFQ.ttf' -OutFile 'assets\fonts\Poppins-Medium.ttf'"

:: Download Poppins SemiBold
echo [3/6] Downloading Poppins-SemiBold.ttf...
powershell -Command "Invoke-WebRequest -Uri 'https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLFj_Z1xlFQ.ttf' -OutFile 'assets\fonts\Poppins-SemiBold.ttf'"

:: Download Poppins Bold
echo [4/6] Downloading Poppins-Bold.ttf...
powershell -Command "Invoke-WebRequest -Uri 'https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLCz7Z1xlFQ.ttf' -OutFile 'assets\fonts\Poppins-Bold.ttf'"

:: Download Poppins Light
echo [5/6] Downloading Poppins-Light.ttf...
powershell -Command "Invoke-WebRequest -Uri 'https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLDz8Z1xlFQ.ttf' -OutFile 'assets\fonts\Poppins-Light.ttf'"

:: Download Poppins ExtraLight
echo [6/6] Downloading Poppins-ExtraLight.ttf...
powershell -Command "Invoke-WebRequest -Uri 'https://fonts.gstatic.com/s/poppins/v20/pxiByp8kv8JHgFVrLBT5Z1xlFQ.ttf' -OutFile 'assets\fonts\Poppins-ExtraLight.ttf'"

echo.
echo ========================================
echo  ✅ FONTS DOWNLOADED SUCCESSFULLY!
echo ========================================
echo.
echo Downloaded fonts:
echo  - Poppins-Regular.ttf
echo  - Poppins-Medium.ttf
echo  - Poppins-SemiBold.ttf
echo  - Poppins-Bold.ttf
echo  - Poppins-Light.ttf
echo  - Poppins-ExtraLight.ttf
echo.
echo Location: assets\fonts\
echo.
pause
