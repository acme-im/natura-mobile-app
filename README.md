# NaturaTest App

## Project was generated using:

    flutter create --org=im.acme --project-name=natura -i swift -a java --platforms=ios,android -t app folder_name_here

## Update generated files:

    json_serialization:    
        flutter pub run build_runner build
    
    icons:    
        flutter pub run flutter_launcher_icons:main -f pubspec.yaml
    
    splash screen:    
        flutter pub run flutter_native_splash:create

## Integration Test (on emulator):
    
    flutter drive \
      --driver=test_driver/integration_test.dart \
      --target=integration_test/smoke_test.dart

## Integration Test (on device):

# Install gradle 7.x from web

# Grant permissions:
    
    adb -d shell pm grant im.acme.natura android.permission.RECORD_AUDIO

# After running "gradle wrapper" in app's "android" dir:

    ./gradlew app:connectedAndroidTest -Ptarget=`pwd`/../integration_test/smoke_test.dart

## Build APK for Test Lab:

    pushd android
    flutter build apk
    ./gradlew app:assembleAndroidTest
    ./gradlew app:assembleDebug -Ptarget=integration_test/smoke_test.dart
    popd

# Run Instrumentation Test using:
    
    <flutter_project_directory>/build/app/outputs/apk/debug/<file>.apk
    <flutter_project_directory>/build/app/outputs/apk/androidTest/debug/<file>.apk

## Build Release app:

# Android
    
    flutter build appbundle --dart-define=GOOGLE_API_KEY=xxxPROD_KEYxxx

# iOS
    flutter install ios
    cd ios
    pod update
    cd ..
    flutter clean
    flutter build ipa --dart-define=GOOGLE_API_KEY=xxxPROD_KEYxxx
    
    Open build/ios/archive/Runner.xcarchive in XCode and publish
