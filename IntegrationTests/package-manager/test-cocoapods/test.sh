#! /usr/bin/env bash

set -euxo pipefail

pod install

xcodebuild \
  -scheme MyApp \
  -workspace MyApp.xcworkspace \
  -sdk iphonesimulator \
  clean build | xcpretty