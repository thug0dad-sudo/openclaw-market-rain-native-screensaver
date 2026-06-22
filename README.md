# OpenClaw Market Rain

A native macOS Screen Saver that turns market tickers into a Matrix-style falling rain display.

OpenClaw Market Rain shows stock and crypto symbols as green terminal-style rain, with live quote tokens pulled through the Market Rain API. It includes a native macOS settings panel so you can choose which tickers appear.

## Current version

**Native macOS Screen Saver:** `2.0.0`

## Features

- Native macOS `.saver` bundle
- Matrix-style falling ticker rain
- Live quote tokens through `https://market-rain.vercel.app/api/quotes`
- Configurable ticker list through the Screen Saver Options/Settings panel
- Default symbols: `NVDA,BTC,ETH,RKLB,LUNR,ASTS,PLTR,SPY,QQQ`
- OLED-friendly black background
- Free-use permissive license

## ASCII preview

```text
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│   NVDA $210.69 ▲2.95%                                                │
│   PLTR $___    ▲                                                     │
│   BTC $_____          SPY $746.74 ▲0.78%                             │
│   QQQ $740.62 ▲2.51%                                                 │
│                                                                      │
│        ETH ▼                 RKLB ▲                                  │
│        ASTS $___              NVDA $210.69 ▲2.95%                    │
│                                                                      │
│   LUNR ▲       SPY $746.74 ▲0.78%                                    │
│                                                                      │
│                                                                      │
│ OpenClaw Market Rain · Native macOS Saver · Version 2.0.0 · Live     │
└──────────────────────────────────────────────────────────────────────┘
Settings panel
┌──────────────────────────────────────────────────────┐
│ OpenClaw Market Rain Settings                         │
├──────────────────────────────────────────────────────┤
│ Ticker symbols                                        │
│ Comma-separated, up to 20 symbols.                    │
│ Example: NVDA,SPY,QQQ,BTC,ETH                         │
│                                                      │
│ [ NVDA,BTC,ETH,RKLB,LUNR,ASTS,PLTR,SPY,QQQ         ] │
│                                                      │
│ [ Defaults ]                         [ Cancel ] [Save]│
└──────────────────────────────────────────────────────┘
Download
See DOWNLOAD.md.
The current release zip is stored in this repository at:

release/OpenClawMarketRainNative-v2.0.0.saver.zip
A known-good backup of the working pre-live-quotes version is also stored at:
release/OpenClawMarketRainNative-v1.9.9-working.saver.zip
Install
Download the .saver.zip file.
Double-click the zip to extract it.
Copy the .saver bundle to:
~/Library/Screen Savers/
Open macOS System Settings.
Go to Screen Saver.
Select OpenClaw Market Rain 2.0.0.
Click Options/Settings to set ticker symbols.
Development
Build locally:
./build.sh
Install locally:
./install.sh
Project notes
The native screensaver renderer is implemented in Swift/AppKit and uses macOS ScreenSaver APIs. The live quote source is the Market Rain web API.
License
Free-use software under the MIT License. See LICENSE.
