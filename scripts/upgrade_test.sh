#!/usr/bin/env bash
# Checks a real upgrade the way a store update does it: installs 3.0.0,
# saves data with it (including the lifespan increase that 3.0.0 stored
# with shifted week ids), then installs this version over it and checks the
# data. Takes several minutes: the old version is built from its tag.
#
# Usage: scripts/upgrade_test.sh [ios|android]   (default: ios)
set -euo pipefail
cd "$(dirname "$0")/.."

PLATFORM="${1:-ios}"
FROM_TAG="${FROM_TAG:-v3.0.0}"
IPHONE_NAME="${IPHONE_NAME:-iPhone 17}"
ANDROID_PHONE_AVD="${ANDROID_PHONE_AVD:-lc_phone}"
# shellcheck source=scripts/devices.sh
source scripts/devices.sh

WORK=$(mktemp -d)
OLD="$WORK/app"
finish() {
  stop_started_devices
  git worktree remove --force "$OLD" >/dev/null 2>&1 || true
  rm -rf "$WORK"
}
trap finish EXIT

echo "=== Preparing $FROM_TAG"
git worktree add --quiet --detach "$OLD" "$FROM_TAG"
mkdir -p "$OLD/integration_test/upgrade"
cp integration_test/support.dart "$OLD/integration_test/"
cp integration_test/upgrade/seed_3_0_0.dart "$OLD/integration_test/upgrade/"
python3 - "$OLD" <<'PY'
import sys
old = sys.argv[1]
# The old version has no integration_test dependency yet.
path = f'{old}/pubspec.yaml'
text = open(path).read()
anchor = 'dev_dependencies:\n  flutter_test:\n    sdk: flutter\n'
if 'integration_test:' not in text:
    text = text.replace(anchor, anchor + '  integration_test:\n    sdk: flutter\n', 1)
open(path, 'w').write(text)
# Same fix as in this version: the Crashlytics symbol upload breaks
# command line builds outside the release configuration.
path = f'{old}/ios/Runner.xcodeproj/project.pbxproj'
text = open(path).read()
anchor = 'PATH=\\"${PATH}:$FLUTTER_ROOT/bin:${PUB_CACHE}/bin:$HOME/.pub-cache/bin\\"\\n\\n'
guard = 'if [ \\"${CONFIGURATION}\\" != \\"Release\\" ]; then\\n  exit 0\\nfi\\n\\n'
if guard not in text:
    text = text.replace(anchor, anchor + guard, 1)
open(path, 'w').write(text)
PY
# Reuse the Swift packages this checkout already downloaded.
if [ -d build/ios/SourcePackages ]; then
  mkdir -p "$OLD/build/ios"
  cp -Rc build/ios/SourcePackages "$OLD/build/ios/" 2>/dev/null ||
    cp -R build/ios/SourcePackages "$OLD/build/ios/"
fi

case "$PLATFORM" in
  ios) boot_ios "$IPHONE_NAME"; FLAVOR=() ;;
  android) boot_android "$ANDROID_PHONE_AVD" 5564; FLAVOR=(--flavor lifeCalendarTest) ;;
  *) echo "Unknown platform: $PLATFORM" >&2; exit 2 ;;
esac

echo "=== Saving data with $FROM_TAG on $DEVICE"
(
  cd "$OLD"
  "${FLUTTER[@]}" pub get >/dev/null
  "${FLUTTER[@]}" test integration_test/upgrade/seed_3_0_0.dart \
    -d "$DEVICE" "${FLAVOR[@]+"${FLAVOR[@]}"}" --no-uninstall
)

echo "=== Installing this version over it"
"${FLUTTER[@]}" test integration_test/upgrade/verify_upgrade.dart \
  -d "$DEVICE" "${FLAVOR[@]+"${FLAVOR[@]}"}"
