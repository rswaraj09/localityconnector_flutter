@echo off
echo Cleaning project...
flutter clean

echo Removing build directories...
if exist "build" rmdir /s /q build
if exist "android\app\build" rmdir /s /q android\app\build

echo Setting proper local properties...
echo sdk.dir=C:\\Users\\ASUS\\AppData\\Local\\Android\\sdk > android\local.properties
echo flutter.sdk=D:\\Downloads\\flutter >> android\local.properties
echo flutter.buildMode=debug >> android\local.properties
echo flutter.versionName=1.0.0 >> android\local.properties
echo flutter.versionCode=1 >> android\local.properties
echo flutter.project.dir=D:\\PROJECTS\\LOCALITY_CONNECTOR_FLUTTER\\localityconnector\\localityconnector\\localityconnector >> android\local.properties

echo Getting dependencies...
flutter pub get

echo Ready to build! Now run: flutter run -d your-device-id 