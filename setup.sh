#!/usr/bin/env bash
set -e
rm -rf .aiiz_backup
mkdir .aiiz_backup
cp -R lib assets web .aiiz_backup/
cp pubspec.yaml analysis_options.yaml .aiiz_backup/
flutter create . --project-name aiiz_check --org com.aiizcheck --platforms=android,web,linux,macos
rm -rf lib assets web
cp -R .aiiz_backup/lib .aiiz_backup/assets .aiiz_backup/web .
cp .aiiz_backup/pubspec.yaml .aiiz_backup/analysis_options.yaml .
rm -rf .aiiz_backup
flutter pub get
dart run flutter_launcher_icons || true
flutter analyze || true
echo "Selesai. Jalankan: flutter run"
