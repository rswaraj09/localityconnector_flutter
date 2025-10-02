@echo off
echo Fixing Java and Gradle issues...

echo Setting JAVA_HOME to a compatible version...
set JAVA_HOME=C:\Program Files\Java\jdk-17
echo JAVA_HOME set to %JAVA_HOME%

echo Setting ANDROID_HOME...
set ANDROID_HOME=C:\Users\ASUS\AppData\Local\Android\sdk
echo ANDROID_HOME set to %ANDROID_HOME%

echo Cleaning project...
call flutter clean

echo Updating project-level files...
cd android

echo Creating project.properties file...
(
echo android.useAndroidX=true
echo android.enableJetifier=true
) > project.properties

echo Setting gradlew executable permissions...
attrib +x gradlew

echo Getting dependencies...
cd ..
call flutter pub get

echo Ready to build! Now run: flutter run -d your-device-id 