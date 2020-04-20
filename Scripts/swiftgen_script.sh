#!/bin/sh

if which mint >/dev/null && mint list | grep "SwiftGen" >/dev/null; then
  mint run swiftgen swiftgen
else
  swiftgen
fi
