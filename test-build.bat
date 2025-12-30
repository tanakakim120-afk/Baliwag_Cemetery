@echo off
echo 🚀 Testing Flutter Web Build Locally...
echo.

echo 📁 Checking build directory...
if not exist "build\web" (
    echo ❌ Build directory not found. Run 'flutter build web --release' first.
    pause
    exit /b 1
)

echo ✅ Build directory found.

echo 🌐 Starting local server...
echo 📱 Open your browser and go to: http://localhost:8080
echo.
echo Press Ctrl+C to stop the server
echo.

cd build\web
python -m http.server 8080

pause
