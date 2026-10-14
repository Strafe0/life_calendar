# Shared helpers for starting simulators and emulators.
# Sourced by integration_tests.sh and upgrade_test.sh.

ANDROID_SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
ADB="$ANDROID_SDK/platform-tools/adb"
FLUTTER=(fvm flutter)
command -v fvm >/dev/null || FLUTTER=(flutter)

started_ios=()
started_android=()

# Newest available simulator with exactly this name.
ios_udid() {
  xcrun simctl list devices available -j | python3 -c '
import json, sys
name = sys.argv[1]
runtimes = json.load(sys.stdin)["devices"]
for runtime in sorted(runtimes, reverse=True):
    for device in runtimes[runtime]:
        if device["name"] == name:
            print(device["udid"])
            sys.exit(0)
sys.exit(1)' "$1"
}

# Boots the simulator if needed and sets DEVICE to its id.
boot_ios() {
  local udid
  udid=$(ios_udid "$1") || { echo "No simulator named '$1'" >&2; return 1; }
  if ! xcrun simctl list devices | grep "$udid" | grep -q Booted; then
    xcrun simctl boot "$udid" && started_ios+=("$udid")
  fi
  xcrun simctl bootstatus "$udid" -b >/dev/null
  DEVICE=$udid
}

# Starts the emulator if needed and sets DEVICE to its serial.
boot_android() {
  local avd=$1 port=$2 serial="emulator-$2"
  if ! "$ADB" devices | grep -q "^$serial"; then
    "$ANDROID_SDK/emulator/emulator" -avd "$avd" -port "$port" \
      -no-snapshot-save -no-audio -no-boot-anim >/dev/null 2>&1 &
    started_android+=("$serial")
  fi
  "$ADB" -s "$serial" wait-for-device
  until [ "$("$ADB" -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; do
    sleep 2
  done
  DEVICE=$serial
}

stop_started_devices() {
  # The ${a[@]+...} form keeps bash 3.2 (macOS) from failing on empty arrays.
  for udid in ${started_ios[@]+"${started_ios[@]}"}; do
    xcrun simctl shutdown "$udid" 2>/dev/null
  done
  for serial in ${started_android[@]+"${started_android[@]}"}; do
    "$ADB" -s "$serial" emu kill >/dev/null 2>&1
  done
}
