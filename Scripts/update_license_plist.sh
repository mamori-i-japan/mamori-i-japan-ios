#!/bin/sh

base_dir="TraceCovid19"
output_path="${base_dir}/Resources/Settings.bundle"
name="Acknowledgements"
swiftpm="TraceCovid19.xcworkspace/xcshareddata/swiftpm/Package.swift"

mint run LicensePlist\
  --output-path ${output_path}\
  --suppress-opening-directory\
  --prefix ${name}\
  --package-path ${swiftpm}\
  --single-page
