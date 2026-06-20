#!/bin/bash
set -euo pipefail

./build.sh

mkdir -p "$HOME/Library/Screen Savers"
rm -rf "$HOME/Library/Screen Savers/OpenClawMarketRain.saver"
cp -R build/OpenClawMarketRain.saver "$HOME/Library/Screen Savers/"

echo "Installed to: $HOME/Library/Screen Savers/OpenClawMarketRain.saver"
