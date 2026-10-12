#!/usr/bin/env bash
# Runs the integration tests (integration_test/app_test.dart) on simulators
# and emulators, one device after another.
#
# Usage: scripts/integration_tests.sh [--parallel] [iphone] [ipad] [android-phone] [android-tablet]
# Without device names it runs on all four. Device names can be changed with
# IPHONE_NAME, IPAD_NAME, ANDROID_PHONE_AVD and ANDROID_TABLET_AVD.
#
# --parallel runs the iOS and the Android devices at the same time, about
# twice as fast. Within a platform devices still take turns: they share one
# build folder. Each platform writes to its own log in build/integration_logs.
set -uo pipefail
cd "$(dirname "$0")/.."

IPHONE_NAME="${IPHONE_NAME:-iPhone 17}"
IPAD_NAME="${IPAD_NAME:-iPad Pro 13-inch (M5)}"
ANDROID_PHONE_AVD="${ANDROID_PHONE_AVD:-lc_phone}"
ANDROID_TABLET_AVD="${ANDROID_TABLET_AVD:-lc_tablet}"
# shellcheck source=scripts/devices.sh
source scripts/devices.sh

parallel=0
targets=()
for arg in "$@"; do
  if [ "$arg" = --parallel ]; then parallel=1; else targets+=("$arg"); fi
done
[ ${#targets[@]} -eq 0 ] && targets=(iphone ipad android-phone android-tablet)

if [ $parallel = 1 ]; then
  ios=()
  android=()
  for target in "${targets[@]}"; do
    case "$target" in
      iphone | ipad) ios+=("$target") ;;
      android-*) android+=("$target") ;;
      *) echo "Unknown target: $target" >&2; exit 2 ;;
    esac
  done
  logs=build/integration_logs
  mkdir -p "$logs"
  rm -f "$logs"/*.log
  pids=()
  for platform in ios android; do
    if [ $platform = ios ]; then
      group=(${ios[@]+"${ios[@]}"})
    else
      group=(${android[@]+"${android[@]}"})
    fi
    [ ${#group[@]} -eq 0 ] && continue
    echo "=== ${group[*]}: $logs/$platform.log"
    scripts/integration_tests.sh "${group[@]}" >"$logs/$platform.log" 2>&1 &
    pids+=($!)
  done
  failed=0
  for pid in "${pids[@]}"; do
    wait "$pid" || failed=1
  done
  echo
  cat "$logs"/*.log | grep -E '^(PASS|FAIL)  '
  exit $failed
fi

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
