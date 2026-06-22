
Download OpenClaw Market Rain
Latest version
OpenClaw Market Rain 2.0.0
release/OpenClawMarketRainNative-v2.0.0.saver.zip
Known-good backup
The last confirmed working version before live quotes and ticker settings:
release/OpenClawMarketRainNative-v1.9.9-working.saver.zip
What you get
OpenClawMarketRainNative-v200.saver
├── Contents
│   ├── Info.plist
│   ├── MacOS
│   │   └── OpenClawMarketRainNative
│   └── Resources
│       ├── app.js
│       ├── index.html
│       └── styles.css
Install instructions
1. Download the zip.
2. Extract it.
3. Move the .saver bundle to:
   ~/Library/Screen Savers/
4. Open System Settings.
5. Go to Screen Saver.
6. Select OpenClaw Market Rain 2.0.0.
7. Use Options/Settings to configure tickers.
ASCII install flow
┌──────────────┐     ┌──────────────┐     ┌─────────────────────────┐
│ Download ZIP │ ──▶ │ Extract .saver│ ──▶ │ ~/Library/Screen Savers │
└──────────────┘     └──────────────┘     └─────────────────────────┘
                                                        │
                                                        ▼
                                      ┌──────────────────────────────┐
                                      │ System Settings → Screen Saver│
                                      └──────────────────────────────┘
                                                        │
                                                        ▼
                                      ┌──────────────────────────────┐
                                      │ Select OpenClaw Market Rain   │
                                      └──────────────────────────────┘
Live quote requirement
The screensaver fetches quote tokens from:
https://market-rain.vercel.app/api/quotes
The API must be configured with a quote provider key for true live quotes. The current web deployment has FINNHUB_API_KEY configured and returned source: finnhub-live during verification.
License
OpenClaw Market Rain is free-use software under the MIT License.
You may use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, subject to the license terms.
