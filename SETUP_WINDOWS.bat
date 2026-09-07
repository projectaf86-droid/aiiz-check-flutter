@echo off
chcp 65001 >nul
setlocal EnableExtensions

echo ==============================================
echo   SETUP aiiz.__ Check - Flutter Project
echo ==============================================
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter belum ditemukan di PATH.
  echo Install Flutter SDK dan Android Studio/SDK dulu, lalu buka terminal baru.
  pause
  exit /b 1
)

if exist .aiiz_backup rmdir /s /q .aiiz_backup
mkdir .aiiz_backup
xcopy /e /i /q lib .aiiz_backup\lib >nul
xcopy /e /i /q assets .aiiz_backup\assets >nul
xcopy /e /i /q web .aiiz_backup\web >nul
copy /y pubspec.yaml .aiiz_backup\pubspec.yaml >nul
copy /y analysis_options.yaml .aiiz_backup\analysis_options.yaml >nul

echo [1/5] Membuat platform Android/Web/Windows...
flutter create . --project-name aiiz_check --org com.aiizcheck --platforms=android,web,windows
if errorlevel 1 goto :error

echo [2/5] Mengembalikan source aiiz.__ Check...
if exist lib rmdir /s /q lib
if exist assets rmdir /s /q assets
if exist web rmdir /s /q web
xcopy /e /i /q .aiiz_backup\lib lib >nul
xcopy /e /i /q .aiiz_backup\assets assets >nul
xcopy /e /i /q .aiiz_backup\web web >nul
copy /y .aiiz_backup\pubspec.yaml pubspec.yaml >nul
copy /y .aiiz_backup\analysis_options.yaml analysis_options.yaml >nul
rmdir /s /q .aiiz_backup

echo [3/5] Mengambil package...
flutter pub get
if errorlevel 1 goto :error

echo [4/5] Membuat launcher icon aplikasi...
dart run flutter_launcher_icons
if errorlevel 1 echo Pembuatan launcher icon gagal, tapi source aplikasi tetap bisa dijalankan.

echo [5/5] Cek project...
flutter analyze
if errorlevel 1 echo Ada warning/error analyzer. Baca output di atas dan README.md.

echo.
echo ==============================================
echo Setup selesai.
echo Buka folder ini di VS Code lalu pilih device,
echo kemudian tekan F5 atau jalankan: flutter run
echo ==============================================
pause
exit /b 0

:error
echo Setup gagal. Baca README.md bagian troubleshooting.
pause
exit /b 1
