# Set variables
$DeviceSize = "1440x3120"
$ON_DEVICE_OUTPUT_FILE = "/sdcard/test_video.mp4"
$OUTPUT_VIDEO = "test_video.mp4"
$DRIVER_PATH = "./test_driver/integration_test_driver.dart"
$TEST_PATH = "./integration_test/integration_test.dart"
$DeviceId = "emulator-5554"

# Start screen recording
Start-Process -NoNewWindow -FilePath adb -ArgumentList "shell screenrecord --bit-rate 6000000 $ON_DEVICE_OUTPUT_FILE" -PassThru

# Run the Flutter drive test
flutter drive --device-id=$DeviceId --driver=$DRIVER_PATH --target=$TEST_PATH

# Wait for screenrecord to complete
Start-Sleep -Seconds 5

# Pull the video file from the device
adb pull $ON_DEVICE_OUTPUT_FILE $OUTPUT_VIDEO