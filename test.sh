echo "======= Test Combine ======= "
xcodebuild test \
  -version 11.0 \
  -project Specs/Specs.xcodeproj \
  -scheme Specs \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone Xʀ,OS=13.0' \
  | xcpretty

echo "======= Test CombineX ======= "
