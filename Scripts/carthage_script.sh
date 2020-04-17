#!/bin/sh

if which mint >/dev/null && mint list | grep "Carthage" >/dev/null; then
  mint run carthage carthage copy-frameworks
else
  /usr/local/bin/carthage copy-frameworks
fi
