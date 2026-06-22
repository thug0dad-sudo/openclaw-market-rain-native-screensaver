import ScreenSaver
import AppKit
import Foundation

@objc(OpenClawMarketRainView)
final class OpenClawMarketRainView: ScreenSaverView {
    struct Stream {
        var x: CGFloat
        var y: CGFloat
        var speed: CGFloat
        var tokens: [String]
    }

    private var streams: [Stream] = []
    private var tickers: [String] = []
    private var liveTokens: [String] = []
    private var lastQuoteFetch = Date.distantPast
    private var isFetchingQuotes = false
    private var settingsPanel: NSPanel?
    private var tickerField: NSTextField?

    private let defaultsKey = "OpenClawMarketRainTickers"
    private let defaultTickerCSV = "NVDA,BTC,ETH,RKLB,LUNR,ASTS,PLTR,SPY,QQQ"
    private let version = "2.0.0-NATIVE"
    private let font = NSFont.monospacedSystemFont(ofSize: 18, weight: .regular)
    private let hudFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        animationTimeInterval = 1.0 / 30.0
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        loadTickers()
        refreshQuotes(force: true)
        resetStreams()
    }

    private func loadTickers() {
        let saved = UserDefaults.standard.string(forKey: defaultsKey) ?? defaultTickerCSV
        var clean: [String] = []

        for part in saved.split(separator: ",") {
            let symbol = part.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if !symbol.isEmpty && !clean.contains(symbol) {
                clean.append(symbol)
            }
            if clean.count >= 20 { break }
        }

        if clean.isEmpty {
            clean = defaultTickerCSV.split(separator: ",").map { String($0) }
        }

        tickers = clean
    }

    private func tickerCSV() -> String {
        tickers.joined(separator: ",")
    }

    private func saveTickerCSV(_ csv: String) {
        UserDefaults.standard.set(csv, forKey: defaultsKey)
        UserDefaults.standard.synchronize()

        loadTickers()
        liveTokens = []
        lastQuoteFetch = .distantPast
        refreshQuotes(force: true)
        resetStreams()
    }

    private func quoteURL() -> URL? {
        var components = URLComponents(string: "https://market-rain.vercel.app/api/quotes")
        components?.queryItems = [
            URLQueryItem(name: "symbols", value: tickerCSV())
        ]
        return components?.url
    }

    private func refreshQuotes(force: Bool = false) {
        if isFetchingQuotes { return }
        if !force && Date().timeIntervalSince(lastQuoteFetch) < 30 { return }
        guard let url = quoteURL() else { return }

        isFetchingQuotes = true
        lastQuoteFetch = Date()

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self else { return }

            defer {
                DispatchQueue.main.async {
                    self.isFetchingQuotes = false
                }
            }

            guard error == nil, let data else { return }

            guard
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let quotes = json["quotes"] as? [[String: Any]]
            else { return }

            var tokens: [String] = []

            for quote in quotes {
                guard let symbol = quote["symbol"] as? String else { continue }

                let price: Double?
                if let n = quote["price"] as? NSNumber {
                    price = n.doubleValue
                } else {
                    price = quote["price"] as? Double
                }

                let change: Double?
                if let n = quote["changePercent"] as? NSNumber {
                    change = n.doubleValue
                } else if let n = quote["changePct"] as? NSNumber {
                    change = n.doubleValue
                } else if let d = quote["changePercent"] as? Double {
                    change = d
                } else {
                    change = quote["changePct"] as? Double
                }

                guard let price else { continue }

                if let change {
                    let arrow = change >= 0 ? "▲" : "▼"
                    tokens.append(String(format: "%@ $%.2f %@%.2f%%", symbol, price, arrow, abs(change)))
                } else {
                    tokens.append(String(format: "%@ $%.2f", symbol, price))
                }
            }

            guard !tokens.isEmpty else { return }

            DispatchQueue.main.async {
                self.liveTokens = tokens
            }
        }.resume()
    }

    private func token() -> String {
        if !liveTokens.isEmpty && Int.random(in: 0..<100) < 80 {
            return liveTokens.randomElement() ?? "NVDA"
        }

        let symbol = tickers.randomElement() ?? "NVDA"
        let r = CGFloat.random(in: 0...1)

        if r < 0.55 { return symbol }
        if r < 0.75 { return symbol + (Bool.random() ? "▲" : "▼") }
        if r < 0.90 {
            return String(format: "%@%.2f%%", Bool.random() ? "+" : "-", CGFloat.random(in: 0.1...5.0))
        }
        return String(format: "$%.2f", CGFloat.random(in: 1...500))
    }

    private func makeStream(x: CGFloat) -> Stream {
        Stream(
            x: x,
            y: bounds.height + CGFloat.random(in: 0...600),
            speed: CGFloat.random(in: 1.8...4.2),
            tokens: (0..<24).map { _ in token() }
        )
    }

    private func resetStreams() {
        let width = max(bounds.width, 800)
        let count = max(12, Int(width / 86))
        streams = (0..<count).map { makeStream(x: CGFloat($0) * 86 + 12) }
    }

    override func animateOneFrame() {
        if streams.isEmpty { resetStreams() }
        refreshQuotes(force: false)

        for i in streams.indices {
            // AppKit origin is bottom-left. Decreasing y is visually top-to-bottom.
            streams[i].y -= streams[i].speed

            if streams[i].y + CGFloat(streams[i].tokens.count * 22) < 0 {
                streams[i] = makeStream(x: streams[i].x)
                streams[i].y = bounds.height + CGFloat.random(in: 0...250)
            }

            streams[i].tokens.removeLast()
            streams[i].tokens.insert(token(), at: 0)
        }

        needsDisplay = true
    }

    override func draw(_ rect: NSRect) {
        NSColor.black.setFill()
        rect.fill()

        for stream in streams {
            for (idx, text) in stream.tokens.enumerated() {
                let y = stream.y + CGFloat(idx * 22)
                if y < -40 || y > bounds.height + 40 { continue }

                let alpha = max(0.05, 1.0 - CGFloat(idx) / CGFloat(stream.tokens.count))
                let color = idx == 0
                    ? NSColor(calibratedRed: 0.85, green: 1.0, blue: 0.85, alpha: 1.0)
                    : NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.35, alpha: alpha * 0.85)

                text.draw(
                    at: NSPoint(x: stream.x, y: y),
                    withAttributes: [.font: font, .foregroundColor: color]
                )
            }
        }

        let source = liveTokens.isEmpty ? "Waiting for quotes" : "Live quotes"
        let hud = "OpenClaw Market Rain · Native macOS Saver · Version \(version) · \(source) · \(tickerCSV())"

        hud.draw(
            at: NSPoint(x: 14, y: 14),
            withAttributes: [
                .font: hudFont,
                .foregroundColor: NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.35, alpha: 0.95)
            ]
        )
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        resetStreams()
    }

    override var hasConfigureSheet: Bool {
        true
    }

    override var configureSheet: NSWindow? {
        if let settingsPanel { return settingsPanel }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 540, height: 220),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )

        panel.title = "OpenClaw Market Rain Settings"

        guard let content = panel.contentView else {
            settingsPanel = panel
            return panel
        }

        let title = NSTextField(labelWithString: "Ticker symbols")
        title.frame = NSRect(x: 24, y: 170, width: 492, height: 24)
        title.font = NSFont.boldSystemFont(ofSize: 15)
        content.addSubview(title)

        let hint = NSTextField(labelWithString: "Comma-separated, up to 20 symbols. Example: NVDA,SPY,QQQ,BTC,ETH")
        hint.frame = NSRect(x: 24, y: 142, width: 492, height: 22)
        hint.textColor = .secondaryLabelColor
        content.addSubview(hint)

        let field = NSTextField(frame: NSRect(x: 24, y: 102, width: 492, height: 28))
        field.stringValue = tickerCSV()
        tickerField = field
        content.addSubview(field)

        let defaults = NSButton(title: "Defaults", target: self, action: #selector(resetTickerSettings(_:)))
        defaults.frame = NSRect(x: 24, y: 38, width: 96, height: 32)
        content.addSubview(defaults)

        let cancel = NSButton(title: "Cancel", target: self, action: #selector(cancelSettings(_:)))
        cancel.frame = NSRect(x: 318, y: 38, width: 88, height: 32)
        content.addSubview(cancel)

        let save = NSButton(title: "Save", target: self, action: #selector(saveSettings(_:)))
        save.frame = NSRect(x: 428, y: 38, width: 88, height: 32)
        save.keyEquivalent = "\r"
        content.addSubview(save)

        settingsPanel = panel
        return panel
    }

    @objc private func resetTickerSettings(_ sender: Any?) {
        tickerField?.stringValue = defaultTickerCSV
    }

    @objc private func cancelSettings(_ sender: Any?) {
        if let settingsPanel {
            NSApp.endSheet(settingsPanel)
        }
    }

    @objc private func saveSettings(_ sender: Any?) {
        saveTickerCSV(tickerField?.stringValue ?? defaultTickerCSV)
        if let settingsPanel {
            NSApp.endSheet(settingsPanel)
        }
    }
}
