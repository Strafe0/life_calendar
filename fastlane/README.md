fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### prepare_screenshots

```sh
[bundle exec] fastlane prepare_screenshots
```

Copy generated screenshots into the folders deliver and supply read

----


## iOS

### ios download_metadata

```sh
[bundle exec] fastlane ios download_metadata
```

Download the live App Store listing into fastlane/metadata/ios

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Upload App Store texts for the version in pubspec.yaml (force:true skips the preview)

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Replace App Store screenshots (force:true skips the preview)

----


## Android

### android download_metadata

```sh
[bundle exec] fastlane android download_metadata
```

Download the current Google Play listing into fastlane/metadata/android

### android metadata

```sh
[bundle exec] fastlane android metadata
```

Upload Google Play texts (validate_only:true checks without publishing)

### android screenshots

```sh
[bundle exec] fastlane android screenshots
```

Replace Google Play screenshots and feature graphic (validate_only:true for a dry run)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
