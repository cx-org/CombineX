#! /usr/bin/env bash

brew install cocoapods

pod install

xcodebuild -scheme test-cocoapods -workspace test-cocoapods.xcworkspace -sdk iphonesimulator clean build