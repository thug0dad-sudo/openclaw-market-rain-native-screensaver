import ScreenSaver
import AppKit

@objc(OpenClawMarketRainView)
final class OpenClawMarketRainView: ScreenSaverView {
    struct Stream {
        var x: CGFloat
        var y: CGFloat
        var speed: CGFloat
        var tokens: [String]
    }

    private var streams: [Stream] = []
    private let tickers = ["NVDA", "BTC", "ETH", "RKLB", "LUNR", "ASTS", "PLTR", "SPY", "QQQ"]
    private let version = "1.9.9-NATIVE"
    private let font = NSFont.monospacedSystemFont(ofSize: 18, weight: .regular)
    private let hudFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0 / 30.0
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        resetStreams()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        animationTimeInterval = 1.0 / 30.0
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        resetStreams()
    }

    private func token() -> String {
        let s = tickers.randomElement() ?? "NVDA"
        let r = CGFloat.random(in: 0...1)
        if r < 0.55 { return s }
        if r < 0.75 { return s + (Bool.random() ? "▲" : "▼") }
        if r < 0.90 { return String(format: "%@%.2f%%", Bool.random() ? "+" : "-", CGFloat.random(in: 0.1...5.0)) }
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

        for i in streams.indices {
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

        let hud = "OpenClaw Market Rain · Native macOS Saver · Version \(version)"
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
}
