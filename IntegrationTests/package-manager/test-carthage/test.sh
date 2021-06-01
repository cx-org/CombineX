#! /usr/bin/env bash

brew install carthage

GIT_PATH=$(cd ../../../ && pwd)
echo "git \"${GIT_PATH}\"" >| 'Cartfile'

carthage update --platform ios --use-xcframeworks

xcodebuild -scheme test-carthage -project test-carthage.xcodeproj -sdk iphonesimulator clean build