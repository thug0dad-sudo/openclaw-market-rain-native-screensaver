#!/bin/bash
set -euo pipefail

./build.sh

mkdir -p "$HOME/Library/Screen Savers"
rm -rf "$HOME/Library/Screen Savers/OpenClawMarketRainNative-v191.saver"
cp -R build/OpenClawMarketRainNative-v191.saver "$HOME/Library/Screen Savers/"

echo "Installed to: $HOME/Library/Screen Savers/OpenClawMarketRainNative-v191.saver"
