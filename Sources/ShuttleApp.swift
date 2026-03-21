import SwiftUI
import AppKit

// MARK: - App Entry Point

@main
struct ShuttleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup("Shuttle - URL Fixer", id: "url-fixer") {
            URLFixerView()
        }
        .defaultSize(width: 500, height: 300)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check if launched with command-line arguments
        let args = CommandLine.arguments

        if args.count >= 3 {
            let command = args[1]
            let text = args[2...].joined(separator: " ")

            switch command {
            case "copy":
                handleCopy(text: text)
            case "url":
                handleURL(text: text)
            default:
                break
            }
        } else if args.count == 2 && args[1] == "copy" {
            // Read from stdin
            if let stdinData = readStdin() {
                handleCopy(text: stdinData)
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // When dock icon is clicked, show URL fixer window
        if !flag {
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
        return true
    }

    private func readStdin() -> String? {
        // Check if stdin has data (piped input)
        if isatty(fileno(stdin)) == 0 {
            var input = ""
            while let line = readLine(strippingNewline: false) {
                input += line
            }
            return input.isEmpty ? nil : input
        }
        return nil
    }

    private func handleCopy(text: String) {
        DispatchQueue.main.async {
            let window = CopyPopupWindow(text: text)
            window.show()
        }
    }

    private func handleURL(text: String) {
        let cleaned = text.components(separatedBy: .whitespacesAndNewlines).joined()
        DispatchQueue.main.async {
            let window = CopyPopupWindow(text: cleaned, isURL: true)
            window.show()
        }
    }
}

// MARK: - Copy Popup Window (NSWindow-based for CLI invocation)

class CopyPopupWindow {
    let text: String
    let isURL: Bool
    var window: NSWindow?

    init(text: String, isURL: Bool = false) {
        self.text = text
        self.isURL = isURL
    }

    func show() {
        NSApp.setActivationPolicy(.regular)

        let contentView = NSHostingView(rootView: CopyPopupView(
            text: text,
            isURL: isURL,
            onDismiss: { [weak self] in
                self?.window?.close()
                // If launched from CLI, quit after copy
                if CommandLine.arguments.count >= 2 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NSApp.terminate(nil)
                    }
                }
            }
        ))

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = isURL ? "Shuttle - Clean URL" : "Shuttle - Copy to Clipboard"
        window.contentView = contentView
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.level = .floating

        NSApp.activate(ignoringOtherApps: true)

        self.window = window
    }
}

// MARK: - Copy Popup View

struct CopyPopupView: View {
    let text: String
    let isURL: Bool
    let onDismiss: () -> Void
    @State private var copied = false

    var body: some View {
        VStack(spacing: 16) {
            Text(isURL ? "Clean URL" : "Text from Terminal")
                .font(.headline)
                .padding(.top, 12)

            ScrollView {
                Text(text)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

            HStack(spacing: 12) {
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        onDismiss()
                    }
                }) {
                    Label(copied ? "Copied!" : "Copy to Clipboard", systemImage: copied ? "checkmark.circle.fill" : "doc.on.doc")
                        .frame(minWidth: 150)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(copied ? .green : .blue)

                if isURL {
                    Button(action: {
                        if let url = URL(string: text) {
                            NSWorkspace.shared.open(url)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onDismiss()
                        }
                    }) {
                        Label("Open in Browser", systemImage: "safari")
                            .frame(minWidth: 150)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button("Close") {
                    onDismiss()
                }
                .controlSize(.large)
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 20)
        .frame(minWidth: 500, minHeight: 250)
    }
}

// MARK: - URL Fixer View (Main window when app is opened from Dock)

struct URLFixerView: View {
    @State private var inputText = ""
    @State private var cleanedURL = ""
    @State private var copied = false

    var body: some View {
        VStack(spacing: 16) {
            Text("URL Fixer")
                .font(.title)
                .fontWeight(.bold)

            Text("Paste a broken URL (with line breaks from terminal wrapping) and get a clean one.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            TextEditor(text: $inputText)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 80)
                .border(Color.gray.opacity(0.3), width: 1)
                .onChange(of: inputText) {
                    cleanedURL = inputText
                        .components(separatedBy: .whitespacesAndNewlines)
                        .joined()
                    copied = false
                }

            if !cleanedURL.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Clean URL:")
                        .font(.headline)

                    Text(cleanedURL)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(6)
                }

                HStack(spacing: 12) {
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(cleanedURL, forType: .string)
                        copied = true
                    }) {
                        Label(copied ? "Copied!" : "Copy Clean URL", systemImage: copied ? "checkmark.circle.fill" : "doc.on.doc")
                            .frame(minWidth: 140)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(copied ? .green : .blue)

                    Button(action: {
                        if let url = URL(string: cleanedURL) {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Label("Open in Browser", systemImage: "safari")
                            .frame(minWidth: 140)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    Button("Clear") {
                        inputText = ""
                        cleanedURL = ""
                        copied = false
                    }
                    .controlSize(.large)
                }
            }

            Spacer()
        }
        .padding(20)
        .frame(minWidth: 500, minHeight: 300)
    }
}
