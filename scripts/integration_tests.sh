#!/usr/bin/env bash
# Runs the integration tests (integration_test/app_test.dart) on simulators
# and emulators, one device after another.
#
# Usage: scripts/integration_tests.sh [iphone] [ipad] [android-phone] [android-tablet]
# Without arguments it runs on all four. Device names can be changed with
# IPHONE_NAME, IPAD_NAME, ANDROID_PHONE_AVD and ANDROID_TABLET_AVD.
set -uo pipefail
cd "$(dirname "$0")/.."

IPHONE_NAME="${IPHONE_NAME:-iPhone 17}"
IPAD_NAME="${IPAD_NAME:-iPad Pro 13-inch (M5)}"
ANDROID_PHONE_AVD="${ANDROID_PHONE_AVD:-lc_phone}"
ANDROID_TABLET_AVD="${ANDROID_TABLET_AVD:-lc_tablet}"
# shellcheck source=scripts/devices.sh
source scripts/devices.sh

targets=("$@")
[ ${#targets[@]} -eq 0 ] && targets=(iphone ipad android-phone android-tablet)

results=()
failed=0

run_on() {
  local label=$1 device=$2
  shift 2
  echo "=== $label ($device)"
  if "${FLUTTER[@]}" test integration_test/app_test.dart -d "$device" "$@"; then
    results+=("PASS  $label")
  else
    results+=("FAIL  $label")
    failed=1
  fi
}

trap stop_started_devices EXIT

for target in "${targets[@]}"; do
  DEVICE=
  case "$target" in
    iphone) boot_ios "$IPHONE_NAME" && run_on "$IPHONE_NAME" "$DEVICE" ;;
    ipad) boot_ios "$IPAD_NAME" && run_on "$IPAD_NAME" "$DEVICE" ;;
    android-phone)
      boot_android "$ANDROID_PHONE_AVD" 5560 &&
        run_on "$ANDROID_PHONE_AVD" "$DEVICE" --flavor lifeCalendarTest ;;
    android-tablet)
      boot_android "$ANDROID_TABLET_AVD" 5562 &&
        run_on "$ANDROID_TABLET_AVD" "$DEVICE" --flavor lifeCalendarTest ;;
    *) echo "Unknown target: $target" >&2; false ;;
  esac || [ -n "$DEVICE" ] || { results+=("FAIL  $target (no device)"); failed=1; }
done

echo
printf '%s\n' ${results[@]+"${results[@]}"}
exit $failed
