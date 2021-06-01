#! /usr/bin/env bash

pod install

xcodebuild \
  -scheme test-cocoapods \
  -workspace test-cocoapods.xcworkspace \
  -sdk iphonesimulator \
  clean build | xcpretty