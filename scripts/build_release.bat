@echo off
REM Build optimized release artifacts for sawalif_app.
REM
REM Outputs:
REM   - build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk  (older devices)
REM   - build\app\outputs\flutter-apk\app-arm64-v8a-release.apk    (modern devices)
REM   - build\app\outputs\flutter-apk\app-x86_64-release.apk       (emulators)
REM   - build\app\outputs\bundle\release\app-release.aab           (Play Store)
REM
REM Each split APK is ~30-40%% smaller than a universal APK.

setlocal
echo === flutter clean ===
call flutter clean || goto :error

echo === flutter pub get ===
call flutter pub get || goto :error

echo === Building per-ABI APKs (release, minified, R8) ===
call flutter build apk --release --split-per-abi || goto :error

echo === Building App Bundle (recommended for Play Store) ===
call flutter build appbundle --release || goto :error

echo.
echo === Done. Artifacts: ===
dir /B build\app\outputs\flutter-apk\*.apk
dir /B build\app\outputs\bundle\release\*.aab
goto :eof

:error
echo Build failed with error %ERRORLEVEL%.
exit /b %ERRORLEVEL%
