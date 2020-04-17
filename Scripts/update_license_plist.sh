#!/bin/sh

base_dir="TraceCovid19"
output_path="${base_dir}/Resources/Settings.bundle"
name="Acknowledgements"

mint run LicensePlist\
  --output-path ${output_path}\
  --suppress-opening-directory\
  --prefix ${name}\
  --single-page
