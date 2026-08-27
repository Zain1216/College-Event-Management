#!/bin/bash
set -e

# Install Flutter SDK
git clone https://github.com/flutter/flutter.git --depth 1 --branch stable "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

# Enable web and get dependencies
flutter config --enable-web
flutter pub get

# Build Flutter web (no --web-renderer flag, removed in Flutter 3.22+)
flutter build web --release
