#!/usr/bin/env bash

rm -rf /tmp/.window-layout/

time="$(date)"
echo "$time - Removed saved window layouts at boot" > "/tmp/window-layout-clean-saved-layouts.log"

