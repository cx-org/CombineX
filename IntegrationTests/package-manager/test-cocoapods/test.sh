#! /usr/bin/env bash

pod install

xcodebuild \
  -scheme MyApp \
  -workspace MyApp.xcworkspace \
  -sdk iphonesimulator \
  clean build | xcpretty