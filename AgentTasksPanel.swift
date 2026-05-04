import AppKit
import WebKit

final class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandler {
    private var panel: NSPanel!
    private var webView: WKWebView!
    private var statusItem: NSStatusItem!
    private let defaults = UserDefaults.standard
    private let positionKey = "panelPosition"

    func applicationDidFinishLaunching(_ notification: Notification) {
        let target = CommandLine.arguments.dropFirst().first ?? "http://127.0.0.1:8765/"
        let width: CGFloat = 410
        let height: CGFloat = 520
        let position = defaults.string(forKey: positionKey) ?? "top-right"
        let origin = originFor(position: position, size: NSSize(width: width, height: height))

        panel = NSPanel(
            contentRect: NSRect(origin: origin, size: NSSize(width: width, height: height)),
            styleMask: [.nonactivatingPanel, .titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        panel.title = "Fujiko"
        panel.titleVisibility = .visible
        panel.titlebarAppearsTransparent = false
        panel.isMovableByWindowBackground = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.minSize = NSSize(width: 280, height: 240)
        panel.backgroundColor = NSColor.windowBackgroundColor
        panel.isOpaque = true

        let config = WKWebViewConfiguration()
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.userContentController.add(self, name: "panel")
        webView = WKWebView(frame: .zero, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.setValue(false, forKey: "drawsBackground")

        panel.contentView = webView
        panel.makeKeyAndOrderFront(nil)
        NSApp.setActivationPolicy(.accessory)

        installStatusItem()

        if let url = URL(string: target) {
            webView.load(URLRequest(url: url))
        }
    }

    private func installStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = loadStatusIcon()
            button.toolTip = "Fujiko"
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "Show widget", action: #selector(showWidget), keyEquivalent: "")
        menu.addItem(withTitle: "Hide widget", action: #selector(hideWidget), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        let quit = NSMenuItem(title: "Quit Fujiko", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        for entry in menu.items where entry.target == nil { entry.target = self }
        item.menu = menu
        self.statusItem = item
    }

    private func loadStatusIcon() -> NSImage? {
        let exeDir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
        let parent = exeDir.deletingLastPathComponent()
        let candidates = [
            parent.appendingPathComponent("image.png"),
            parent.appendingPathComponent("AgentTasks.icns"),
        ]
        for url in candidates {
            if let image = NSImage(contentsOf: url) {
                image.size = NSSize(width: 18, height: 18)
                return image
            }
        }
        return NSImage(systemSymbolName: "list.bullet.rectangle", accessibilityDescription: "Agent Tasks")
    }

    @objc private func showWidget() {
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
    }

    @objc private func hideWidget() {
        panel.orderOut(nil)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "panel",
              let body = message.body as? [String: Any],
              let action = body["action"] as? String else {
            return
        }

        if action == "move", let position = body["position"] as? String {
            movePanel(to: position)
        }
    }

    private func movePanel(to position: String) {
        let allowed = ["top-left", "top-right", "bottom-left", "bottom-right"]
        guard allowed.contains(position) else { return }

        defaults.set(position, forKey: positionKey)
        let size = panel.frame.size
        let origin = originFor(position: position, size: size)
        panel.setFrameOrigin(origin)
        panel.orderFrontRegardless()
    }

    private func originFor(position: String, size: NSSize) -> NSPoint {
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let margin: CGFloat = 18

        switch position {
        case "top-left":
            return NSPoint(x: screenFrame.minX + margin, y: screenFrame.maxY - size.height - margin)
        case "bottom-left":
            return NSPoint(x: screenFrame.minX + margin, y: screenFrame.minY + margin)
        case "bottom-right":
            return NSPoint(x: screenFrame.maxX - size.width - margin, y: screenFrame.minY + margin)
        default:
            return NSPoint(x: screenFrame.maxX - size.width - margin, y: screenFrame.maxY - size.height - margin)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
