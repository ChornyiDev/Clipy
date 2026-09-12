//
//  CPYPreferencesWindowController.swift
//  Clipy
//  Copyright © 2015-2026 Clipy Project.
//

import Cocoa
import SwiftUI
import Sharing
import Dependencies
import UniformTypeIdentifiers
import KeyHolder
import Magnet
import Combine

final class CPYPreferencesWindowController: NSWindowController, NSWindowDelegate {
    static let sharedController = CPYPreferencesWindowController(window: nil)

    override init(window: NSWindow?) {
        super.init(window: window)
        if window == nil {
            loadWindow()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func loadWindow() {
        AppStorageValues.register()
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        settingsWindow.title = String(localized: "Clipy Settings")
        settingsWindow.titleVisibility = .hidden
        settingsWindow.titlebarAppearsTransparent = true
        settingsWindow.isOpaque = false
        settingsWindow.backgroundColor = .clear
        settingsWindow.minSize = NSSize(width: 680, height: 540)
        settingsWindow.isReleasedWhenClosed = false
        // The remaining XIB panels still use light-only assets.
        settingsWindow.appearance = NSAppearance(named: .aqua)
        settingsWindow.contentViewController = NSHostingController(rootView: TahoeSettingsView())
        settingsWindow.delegate = self
        window = settingsWindow
        settingsWindow.center()
        settingsWindow.setFrameAutosaveName("TahoePreferences")
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(sender)
        window?.makeFirstResponder(window)
    }

    func windowWillClose(_ notification: Notification) {
        window?.endEditing(for: nil)
        NSApp.deactivate()
    }
}

private enum SettingsPane: Int, CaseIterable, Identifiable {
    case general, menu, types, exclude, shortcuts, updates, beta

    var id: Int { rawValue }

    var title: String {
        let entries = [
            ("qS1-uo-9im.title", "General"), ("vEM-JU-92T.title", "Menu"),
            ("avh-w8-RcC.title", "Types"), ("odU-xs-hZL.title", "Exclude"),
            ("qx8-Vm-eow.title", "Shortcuts"), ("N5e-ba-0Q0.title", "Updates"),
            ("Fxs-BH-hPx.title", "Beta")
        ]
        let entry = entries[rawValue]
        return Bundle.main.localizedString(forKey: entry.0, value: entry.1, table: "CPYPreferencesWindowController")
    }

    var symbol: String {
        ["switch.2", "line.3.horizontal", "doc", "nosign", "command", "arrow.triangle.2.circlepath", "capsule.portrait"][rawValue]
    }

    var nibName: String {
        let names = ["General", "Menu", "Type", "ExcludeApp", "Shortcuts", "Updates", "Beta"]
        return "CPY" + names[rawValue] + "PreferenceViewController"
    }

    var height: CGFloat {
        [259, 401, 245, 287, 275, 134, 229][rawValue]
    }

    func makeController() -> NSViewController {
        switch self {
        case .types: return CPYTypePreferenceViewController(nibName: nibName, bundle: nil)
        case .exclude: return CPYExcludeAppPreferenceViewController(nibName: nibName, bundle: nil)
        case .shortcuts: return CPYShortcutsPreferenceViewController(nibName: nibName, bundle: nil)
        case .updates: return CPYUpdatesPreferenceViewController(nibName: nibName, bundle: nil)
        case .beta: return CPYBetaPreferenceViewController(nibName: nibName, bundle: nil)
        default: return NSViewController(nibName: nibName, bundle: nil)
        }
    }
}

private struct TahoeSettingsView: View {
    @State private var selection = SettingsPane.general

    var body: some View {
        VStack(spacing: 0) {
            Text("Clipy Settings")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(red: 0.27, green: 0.30, blue: 0.36))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(Color(red: 0.973, green: 0.969, blue: 0.988))
                .accessibilityAddTraits(.isHeader)
            HStack(spacing: 0) {
                ForEach(SettingsPane.allCases) { pane in
                    Button {
                        selection = pane
                    } label: {
                        VStack(spacing: 4) {
                            Group {
                                if pane == .general {
                                    Capsule()
                                        .stroke(lineWidth: 1.2)
                                        .frame(width: 13, height: 8)
                                        .overlay(Circle().frame(width: 4, height: 4).offset(x: -2.5))
                                } else if pane == .beta {
                                    Text("β")
                                        .font(.system(size: 16, weight: .regular, design: .serif))
                                        .italic()
                                } else {
                                    Image(systemName: pane.symbol)
                                        .font(.system(size: 13, weight: .regular))
                                }
                            }
                            .frame(width: 16, height: 16)
                            Text(pane.title)
                                .font(.system(size: 10.5, weight: .medium))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 64, height: 44)
                        .foregroundStyle(selection == pane ? Color.accentColor : Color(red: 0.38, green: 0.43, blue: 0.50))
                        .background {
                            if selection == pane {
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .settingsFocusStyle()
                    .accessibilityAddTraits(selection == pane ? .isSelected : [])
                    .help(pane.title)
                }
            }
            .padding(4)
            .background(Color(red: 0.914, green: 0.933, blue: 0.953), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black.opacity(0.045)))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 4)
            .padding(.bottom, 14)
            .background(Color(red: 0.973, green: 0.969, blue: 0.988))
            Color(red: 0.935, green: 0.932, blue: 0.950)
                .frame(height: 0.5)
            ScrollView {
                Group {
                    if selection == .general {
                        TahoeGeneralSettings()
                    } else if selection == .menu {
                        TahoeMenuSettings()
                    } else if selection == .types {
                        TahoeTypeSettings()
                    } else if selection == .exclude {
                        TahoeExcludedAppsSettings()
                    } else if selection == .shortcuts {
                        TahoeShortcutSettings()
                    } else if selection == .updates {
                        TahoeUpdateSettings()
                    } else if selection == .beta {
                        TahoeBetaSettings()
                    } else {
                        LegacySettingsPanel(pane: selection)
                            .id(selection)
                            .frame(width: 480, height: selection.height)
                            .padding(20)
                            .background(.white, in: RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.black.opacity(0.06)))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                SettingsBackdrop()
                Color(red: 0.973, green: 0.969, blue: 0.988).opacity(0.65)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .tint(.blue)
    }
}

private struct SettingsBackdrop: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .sidebar
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {}
}

// Shared section treatment for settings panes as they move from XIBs to SwiftUI.
private struct SettingsSection<Content: View>: View {
    let heading: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(heading.uppercased(with: .current))
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.7)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
                .accessibilityAddTraits(.isHeader)
            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.black.opacity(0.06)))
            .shadow(color: .black.opacity(0.025), radius: 3, y: 2)
        }
    }
}

private struct LegacySettingsPanel: NSViewControllerRepresentable {
    let pane: SettingsPane

    func makeNSViewController(context: Context) -> NSViewController { pane.makeController() }
    func updateNSViewController(_ controller: NSViewController, context: Context) {}
}

private struct TahoeGeneralSettings: View {
    private static let historyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.allowsFloats = false
        formatter.minimum = 1
        return formatter
    }()

    @AppStorage(AppStorageKeys.loginItem.rawValue) private var launchAtLogin = false
    @AppStorage(AppStorageKeys.inputPasteCommand.rawValue) private var pasteAutomatically = true
    @AppStorage(AppStorageKeys.collectCrashReport.rawValue) private var sendReports = true
    @AppStorage(AppStorageKeys.maxHistorySize.rawValue) private var historyLimit = 30
    @AppStorage(AppStorageKeys.reorderClipsAfterPasting.rawValue) private var sortByLastUse = true
    @AppStorage(AppStorageKeys.showStatusItem.rawValue) private var iconStyle = 1

    var body: some View {
        VStack(spacing: 18) {
            card(title("nDk-8y-89n", "Behavior")) {
                switchRow(title("Su3-mF-z1T", "Launch on Login"), isOn: $launchAtLogin)
                Divider()
                switchRow(title("0yt-u0-ROt", "Input \"⌘ + V\" after menu item selection"), isOn: $pasteAutomatically)
                Divider()
                switchRow(title("LsC-YB-qAw", "Send crash reports and usage logs (applies next launch)"), isOn: $sendReports)
            }
            card(title("OOT-F5-Pal", "Clipboard History")) {
                HStack(spacing: 16) {
                    Text(title("Nab-CO-ytH", "Max clipboard history size:"))
                    Spacer()
                    TextField("", value: $historyLimit, formatter: Self.historyFormatter)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .monospacedDigit()
                        .frame(width: 80)
                        .accessibilityLabel(title("Nab-CO-ytH", "Max clipboard history size:"))
                    Text(title("eeq-cw-v00", "items"))
                        .foregroundStyle(.secondary)
                }
                Divider()
                HStack {
                    Text(title("Lps-06-dPB", "Sort history order by:"))
                    Spacer(minLength: 16)
                    Picker(title("Lps-06-dPB", "Sort history order by:"), selection: $sortByLastUse) {
                        Text(title("YmS-J6-ERc", "Date Created")).tag(false)
                        Text(title("ju3-6a-6xj", "Last Used")).tag(true)
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 140)
                }
            }
            card(title("FM4-mw-DCx", "Appearance")) {
                HStack {
                    Text(title("Faj-kQ-G1v", "Status Bar icon style:"))
                    Spacer()
                    HStack(spacing: 0) {
                        iconOption(3, symbol: "paperclip", label: String(localized: "Paperclip"))
                        iconOption(4, symbol: "clipboard", label: String(localized: "Clipboard"))
                        iconOption(5, symbol: "circle.fill", label: String(localized: "Dot"))
                        iconOption(0, symbol: "nosign", label: title("aEh-u0-hQR", "None"))
                    }
                    .padding(2)
                    .background(.black.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.black.opacity(0.04)))
                }
            }
        }
        .font(.system(size: 13))
        .toggleStyle(.switch)
        .controlSize(.small)
    }

    private func title(_ identifier: String, _ fallback: String) -> String {
        Bundle.main.localizedString(forKey: identifier + ".title", value: fallback, table: "CPYGeneralPreferenceViewController")
    }

    private func switchRow(_ label: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 16) {
            Text(label)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Toggle(label, isOn: isOn)
                .labelsHidden()
                .fixedSize()
        }
        .frame(maxWidth: .infinity)
    }

    private func iconOption(_ value: Int, symbol: String, label: String) -> some View {
        // Existing filled/outlined clipboard preferences retain their persisted values.
        let selected = iconStyle == value || (value == 4 && (iconStyle == 1 || iconStyle == 2))
        return Button {
            iconStyle = value
        } label: {
            Image(systemName: symbol)
                .font(.system(size: value == 5 ? 7 : 14, weight: .medium))
                .frame(width: 34, height: 24)
                .foregroundStyle(selected ? Color.accentColor : Color.secondary)
                .background {
                    if selected {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .settingsFocusStyle()
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .help(label)
    }

    private func card<Content: View>(_ heading: String, @ViewBuilder content: () -> Content) -> some View {
        SettingsSection(heading: heading) {
            content()
        }
    }
}

private struct TahoeMenuSettings: View {
    @AppStorage(AppStorageKeys.numberOfItemsPlaceInline.rawValue) private var inlineCount = 0
    @AppStorage(AppStorageKeys.numberOfItemsPlaceInsideFolder.rawValue) private var folderCount = 10
    @AppStorage(AppStorageKeys.maxMenuItemTitleLength.rawValue) private var titleLength = 20
    @AppStorage(AppStorageKeys.copySameHistory.rawValue) private var copyDuplicates = true
    @AppStorage(AppStorageKeys.overwriteSameHistory.rawValue) private var moveDuplicates = true
    @AppStorage(AppStorageKeys.menuItemsAreMarkedWithNumbers.rawValue) private var numbers = true
    @AppStorage(AppStorageKeys.menuItemsTitleStartWithZero.rawValue) private var startAtZero = false
    @AppStorage(AppStorageKeys.showIconInTheMenu.rawValue) private var icons = true
    @AppStorage(AppStorageKeys.addNumericKeyEquivalents.rawValue) private var numericKeys = false
    @AppStorage(AppStorageKeys.showToolTipOnMenuItem.rawValue) private var tooltips = true
    @AppStorage(AppStorageKeys.maxLengthOfToolTip.rawValue) private var tooltipLength = 200
    @AppStorage(AppStorageKeys.showColorPreviewInTheMenu.rawValue) private var colors = true
    @AppStorage(AppStorageKeys.showImageInTheMenu.rawValue) private var images = true
    @AppStorage(AppStorageKeys.thumbnailWidth.rawValue) private var width = 100
    @AppStorage(AppStorageKeys.thumbnailHeight.rawValue) private var height = 32
    @AppStorage(AppStorageKeys.addClearHistoryMenuItem.rawValue) private var clearItem = true
    @AppStorage(AppStorageKeys.showAlertBeforeClearHistory.rawValue) private var clearAlert = true

    var body: some View {
        VStack(spacing: 20) {
            SettingsSection(heading: String(localized: "Menu Structure & Capacity")) {
                numberRow("wef-NB-6p6", "Number of items place inline:", value: $inlineCount, minimum: 0, unit: text("Ovp-if-Azp", "items"))
                separator
                numberRow("FP7-VI-YVJ", "Number of items place inside a folder:", value: $folderCount, unit: text("Ovp-if-Azp", "items"))
                separator
                numberRow("hBb-sd-DcP", "Number of characters in the menu:", value: $titleLength, unit: text("67F-2m-Txz", "chars"))
            }
            SettingsSection(heading: String(localized: "Menu Behavior & Sorting")) {
                switchRow("a32-zW-R74", "Place already copied history at the top", value: $copyDuplicates)
                separator
                switchRow("lsx-Y0-zFR", "Move instead of copying (removes the older one from the list)", value: $moveDuplicates)
                    .disabled(!copyDuplicates)
                separator
                switchRow("nMF-6D-hXu", "Mark menu items with numbers", value: $numbers)
                separator
                switchRow("seq-HO-d27", "Menu items' title starts with 0", value: $startAtZero)
                    .disabled(!numbers)
            }
            SettingsSection(heading: String(localized: "Display & Preview")) {
                switchRow("yrU-qO-OwD", "Display icons in menu items", value: $icons)
                separator
                switchRow("hE2-DL-MKl", "Add key equivalents to numeric keys", value: $numericKeys)
                separator
                switchRow("h4n-Nv-zj1", "Show tool tip on a menu item", value: $tooltips)
                numberRow("QFO-xC-Z3p", "Max length of tool tip string:", value: $tooltipLength, unit: text("67F-2m-Txz", "chars"))
                    .disabled(!tooltips)
                separator
                switchRow("hgW-RK-5oy", "Show color code preview", value: $colors)
                separator
                switchRow("Drj-kg-Km5", "Show Image", value: $images)
                numberRow("saf-vP-Qwl", "Width:", value: $width, unit: text("90g-HQ-9Ua", "pixel"))
                    .disabled(!images)
                numberRow("WKb-6V-Q9w", "Height:", value: $height, unit: text("90g-HQ-9Ua", "pixel"))
                    .disabled(!images)
            }
            SettingsSection(heading: String(localized: "Action Items")) {
                switchRow("p80-3o-bgA", "Add a menu item to clear clipboard history", value: $clearItem)
                separator
                switchRow("U2I-bu-kTR", "Show alert panel before clear history", value: $clearAlert)
            }
        }
        .font(.system(size: 13))
        .controlSize(.small)
    }

    private var separator: some View {
        Color.black.opacity(0.055).frame(height: 0.5)
    }

    private func text(_ identifier: String, _ fallback: String) -> String {
        Bundle.main.localizedString(forKey: identifier + ".title", value: fallback, table: "CPYMenuPreferenceViewController")
    }

    private func switchRow(_ identifier: String, _ fallback: String, value: Binding<Bool>) -> some View {
        let label = text(identifier, fallback)
        return HStack(spacing: 16) {
            Text(label).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Toggle(label, isOn: value)
                .labelsHidden()
                .toggleStyle(.switch)
                .fixedSize()
        }
    }

    private func numberRow(_ identifier: String, _ fallback: String, value: Binding<Int>, minimum: Int = 1, unit: String) -> some View {
        let label = text(identifier, fallback)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.allowsFloats = false
        formatter.minimum = NSNumber(value: minimum)
        return HStack(spacing: 12) {
            Text(label).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            TextField("", value: value, formatter: formatter)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
                .frame(width: 64)
                .accessibilityLabel(label)
            Text(unit).foregroundStyle(.secondary).frame(width: 36, alignment: .leading)
        }
    }
}

private struct TahoeTypeSettings: View {
    @Shared(.pasteboardTypeSettings) private var settings
    @AppStorage(AppStorageKeys.ignoreConcealedPasteboardType.rawValue) private var ignoreConcealed = false

    // swiftlint:disable:next large_tuple
    private let formats: [(PasteboardAvailableType, String, String, String, String)] = [
        (.string, "9wr-mR-kmC", "Plain Text", "text.alignleft", "TXT / UTF-8"),
        (.rtf, "xyj-FL-88b", "Rich Text Format (RTF)", "doc.richtext", "RTF"),
        (.rtfd, "Nvy-pc-6hl", "Rich Text Format Directory (RTFD)", "doc.on.doc", "RTFD"),
        (.pdf, "27s-8p-tdh", "PDF", "doc", "PDF"),
        (.filenames, "iO6-7x-OcH", "Filenames", "folder", "URI / Path"),
        (.url, "oXv-rM-kj5", "URL", "link", "http(s)"),
        (.tiff, "lZ0-qQ-qWk", "TIFF Image", "photo", "PNG / TIFF")
    ]

    var body: some View {
        VStack(spacing: 20) {
            SettingsSection(heading: String(localized: "Supported Clipboard Formats")) {
                Text("Select data formats Clipy will monitor and store in history.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                ForEach(formats.indices, id: \.self) { index in
                    let format = formats[index]
                    if index > 0 {
                        Color.black.opacity(0.055).frame(height: 0.5)
                    }
                    HStack(spacing: 12) {
                        Image(systemName: format.3)
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        Text(text(format.1, format.2))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(format.4)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 4))
                        Spacer(minLength: 0)
                        Toggle(text(format.1, format.2), isOn: Binding(
                            get: { settings[format.0] },
                            set: { enabled in $settings.withLock { $0[format.0] = enabled } }
                        ))
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .fixedSize()
                    }
                }
            }
            SettingsSection(heading: String(localized: "Security & Privacy")) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(text("wVB-cH-qgn", "Ignore clipboard data marked as Concealed"))
                        Text("Prevents saving sensitive clipboard content marked by apps such as password managers.")
                            .font(.system(size: 11.5))
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                    Toggle(text("wVB-cH-qgn", "Ignore clipboard data marked as Concealed"), isOn: $ignoreConcealed)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .fixedSize()
                }
            }
        }
        .font(.system(size: 13))
        .controlSize(.small)
    }

    private func text(_ identifier: String, _ fallback: String) -> String {
        Bundle.main.localizedString(forKey: identifier + ".title", value: fallback, table: "CPYTypePreferenceViewController")
    }
}

private struct TahoeExcludedAppsSettings: View {
    @Shared(.excludedApplications) private var applications
    @Dependency(\.excludeAppService) private var service
    @State private var selectedIdentifier: String?

    var body: some View {
        SettingsSection(heading: String(localized: "Excluded Applications")) {
            Text("Clipy will ignore clipboard changes when copying from these applications.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        if applications.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "app.dashed")
                                    .font(.system(size: 26))
                                Text("No excluded applications")
                                Text("Use + to add an application.")
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                        }
                        ForEach(applications, id: \.identifier) { application in
                            Button {
                                selectedIdentifier = application.identifier
                            } label: {
                                HStack(spacing: 12) {
                                    Image(nsImage: icon(for: application))
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(application.name)
                                            .fontWeight(.medium)
                                        Text(application.identifier)
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(selectedIdentifier == application.identifier ? Color.blue.opacity(0.1) : Color.white)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(selectedIdentifier == application.identifier ? .isSelected : [])
                            Color.black.opacity(0.045).frame(height: 0.5)
                        }
                    }
                }
                .frame(height: 220)
                Color.black.opacity(0.045).frame(height: 0.5)
                HStack(spacing: 0) {
                    Button(action: addApplications) {
                        Image(systemName: "plus").frame(width: 30, height: 26)
                    }
                    .help(String(localized: "Add Application"))
                    .accessibilityLabel(String(localized: "Add Application"))
                    Button(action: removeSelected) {
                        Image(systemName: "minus").frame(width: 30, height: 26)
                    }
                    .disabled(!applications.contains { $0.identifier == selectedIdentifier })
                    .help(String(localized: "Remove Selected"))
                    .accessibilityLabel(String(localized: "Remove Selected"))
                    Spacer()
                    Text(applications.count.formatted())
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 12)
                }
                .buttonStyle(.plain)
                .background(Color(red: 0.975, green: 0.976, blue: 0.985))
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.black.opacity(0.07)))
        }
        .font(.system(size: 13))
    }

    private func icon(for application: ApplicationInformation) -> NSImage {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: application.identifier) {
            return NSWorkspace.shared.icon(forFile: url.path)
        }
        return NSImage(systemSymbolName: "app", accessibilityDescription: application.name) ?? NSImage()
    }

    private func addApplications() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.applicationBundle]
        panel.allowsMultipleSelection = true
        panel.resolvesAliases = true
        panel.prompt = String(localized: "Add")
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        guard panel.runModal() == .OK else { return }
        for url in panel.urls {
            guard let info = Bundle(url: url)?.infoDictionary,
                  let application = ApplicationInformation(info: info as [String: AnyObject]) else { continue }
            service.add(with: application)
            selectedIdentifier = application.identifier
        }
    }

    private func removeSelected() {
        guard let application = applications.first(where: { $0.identifier == selectedIdentifier }) else { return }
        service.delete(with: application)
        selectedIdentifier = nil
    }
}

private struct TahoeShortcutSettings: View {
    @Shared(.mainKeyCombo) private var mainCombo
    @Shared(.historyKeyCombo) private var historyCombo
    @Shared(.snippetKeyCombo) private var snippetCombo
    @Shared(.clearHistoryKeyCombo) private var clearCombo
    @Dependency(\.hotKeyService) private var service

    var body: some View {
        VStack(spacing: 20) {
            SettingsSection(heading: title("X5L-5V-1eH", "Menu")) {
                row(title("5sL-G8-1io", "Main:"), description: String(localized: "Open the main clipboard menu."), combo: mainCombo) {
                    service.change(with: .main, keyCombo: $0)
                }
                separator
                row(title("Abl-cO-JwU", "History:"), description: String(localized: "Open recent clipboard history."), combo: historyCombo) {
                    service.change(with: .history, keyCombo: $0)
                }
                separator
                row(title("fXr-ry-5ds", "Snippets:"), description: String(localized: "Open saved snippets."), combo: snippetCombo) {
                    service.change(with: .snippet, keyCombo: $0)
                }
            }
            SettingsSection(heading: title("Txl-Qh-RzP", "History")) {
                row(title("f3b-Ht-X5w", "Clear History:"), description: String(localized: "Clear stored clipboard history."), combo: clearCombo) {
                    service.changeClearHistoryKeyCombo($0)
                }
            }
            Text("Click a shortcut to record a new key combination. Use × to clear it.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
        }
        .font(.system(size: 13))
    }

    private var separator: some View {
        Color.black.opacity(0.055).frame(height: 0.5)
    }

    private func title(_ identifier: String, _ fallback: String) -> String {
        Bundle.main.localizedString(forKey: identifier + ".title", value: fallback, table: "CPYShortcutsPreferenceViewController")
    }

    private func row(_ title: String, description: String, combo: KeyCombo?, onChange: @escaping (KeyCombo?) -> Void) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title).fontWeight(.medium)
                Text(description)
                    .font(.system(size: 11.5))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            ShortcutRecorder(combo: combo, onChange: onChange)
                .frame(width: 150, height: 28)
                .accessibilityLabel(title)
        }
    }
}

private struct ShortcutRecorder: NSViewRepresentable {
    let combo: KeyCombo?
    let onChange: (KeyCombo?) -> Void

    func makeNSView(context: Context) -> RecordView {
        let view = RecordView(frame: NSRect(x: 0, y: 0, width: 150, height: 28))
        view.cornerRadius = 14
        view.borderWidth = 1
        view.borderColor = NSColor.black.withAlphaComponent(0.12)
        view.backgroundColor = .white
        view.tintColor = .systemBlue
        view.keyCombo = combo
        view.didChange = onChange
        return view
    }

    func updateNSView(_ view: RecordView, context: Context) {
        if !view.isRecording { view.keyCombo = combo }
        view.didChange = onChange
    }

    static func dismantleNSView(_ view: RecordView, coordinator: ()) {
        view.endRecording()
        view.didChange = nil
    }
}

private struct TahoeUpdateSettings: View {
    @Dependency(\.sparkle) private var sparkle
    @AppStorage(AppStorageKeys.enableAutomaticCheck.rawValue) private var automatic = true
    @AppStorage(AppStorageKeys.checkInterval.rawValue) private var interval = 86_400
    @State private var lastCheck: Date?

    var body: some View {
        VStack(spacing: 20) {
            SettingsSection(heading: String(localized: "Version")) {
                HStack(spacing: 14) {
                    Image(nsImage: NSImage(named: NSImage.applicationIconName) ?? NSImage())
                        .resizable()
                        .frame(width: 48, height: 48)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Clipy").font(.system(size: 16, weight: .semibold))
                        Text("v\(Bundle.main.appVersion ?? "—")")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                Color.black.opacity(0.055).frame(height: 0.5)
                HStack(spacing: 12) {
                    Image(systemName: "clock").foregroundStyle(.secondary)
                    Text("Last checked")
                    Spacer()
                    if let lastCheck {
                        Text(lastCheck, format: .dateTime.day().month().year().hour().minute())
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Not checked yet").foregroundStyle(.secondary)
                    }
                }
            }
            SettingsSection(heading: String(localized: "Update Settings")) {
                HStack(spacing: 16) {
                    Text(title("Kdw-AL-Nnj", "Automatically check for updates:"))
                    Spacer(minLength: 0)
                    Toggle(title("Kdw-AL-Nnj", "Automatically check for updates:"), isOn: $automatic)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .fixedSize()
                }
                Color.black.opacity(0.055).frame(height: 0.5)
                HStack {
                    Text("Check frequency")
                    Spacer()
                    Picker("Check frequency", selection: $interval) {
                        Text(title("HwP-AM-nID", "Daily")).tag(86_400)
                        Text(title("NBD-wq-yMq", "Weekly")).tag(604_800)
                        Text(title("o5Q-Ao-iQN", "Monthly")).tag(2_592_000)
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(width: 140)
                }
                .disabled(!automatic)
            }
            HStack {
                Link(destination: URL(string: "https://github.com/Clipy/Clipy/releases")!) {
                    Text("Release notes on GitHub")
                }
                Spacer()
                Button(title("DDI-ts-HPE", "Check Now")) {
                    sparkle.checkForUpdates(nil)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 4)
        }
        .font(.system(size: 13))
        .controlSize(.small)
        .onReceive(sparkle.lastUpdateCheckDate().receive(on: DispatchQueue.main)) { value in
            lastCheck = value as? Date
        }
    }

    private func title(_ identifier: String, _ fallback: String) -> String {
        Bundle.main.localizedString(forKey: identifier + ".title", value: fallback, table: "CPYUpdatesPreferenceViewController")
    }
}

private struct TahoeBetaSettings: View {
    @AppStorage(AppStorageKeys.pastePlainText.rawValue) private var plainText = true
    @AppStorage(AppStorageKeys.pastePlainTextModifier.rawValue) private var plainModifier = 0
    @AppStorage(AppStorageKeys.deleteHistory.rawValue) private var deleteHistory = false
    @AppStorage(AppStorageKeys.deleteHistoryModifier.rawValue) private var deleteModifier = 0
    @AppStorage(AppStorageKeys.pasteAndDeleteHistory.rawValue) private var pasteDelete = false
    @AppStorage(AppStorageKeys.pasteAndDeleteHistoryModifier.rawValue) private var pasteDeleteModifier = 0
    @AppStorage(AppStorageKeys.observerScreenshot.rawValue) private var screenshots = false

    var body: some View {
        VStack(spacing: 20) {
            Text(title("c4z-RD-3UN", "Beta settings might be moved to a different pane in future versions."))
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
            SettingsSection(heading: title("6RM-Ow-USQ", "Action")) {
                actionRow("r0C-kF-Q0z", "Paste as PlainText", enabled: $plainText, modifier: $plainModifier)
                separator
                actionRow("sYs-Da-TSj", "Delete from history", enabled: $deleteHistory, modifier: $deleteModifier)
                separator
                actionRow("M5n-Mr-02l", "Paste and delete from history", enabled: $pasteDelete, modifier: $pasteDeleteModifier)
            }
            SettingsSection(heading: title("0f7-ic-bHq", "Screenshot")) {
                HStack(spacing: 16) {
                    Text(title("pgE-3j-ZEy", "Save screenshots in history"))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    Toggle(title("pgE-3j-ZEy", "Save screenshots in history"), isOn: $screenshots)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .fixedSize()
                }
            }
        }
        .font(.system(size: 13))
        .controlSize(.small)
    }

    private var separator: some View {
        Color.black.opacity(0.055).frame(height: 0.5)
    }

    private func title(_ identifier: String, _ fallback: String) -> String {
        Bundle.main.localizedString(forKey: identifier + ".title", value: fallback, table: "CPYBetaPreferenceViewController")
    }

    private func actionRow(_ identifier: String, _ fallback: String, enabled: Binding<Bool>, modifier: Binding<Int>) -> some View {
        let label = title(identifier, fallback)
        return HStack(spacing: 16) {
            Text(label).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Picker(label, selection: modifier) {
                Text("⌘ " + title("gRa-Te-dcH", "Command")).tag(0)
                Text("⇧ " + title("riQ-CH-Kcr", "Shift")).tag(1)
                Text("⌃ " + title("vtQ-7v-nLJ", "Control")).tag(2)
                Text("⌥ " + title("Ncl-nV-zr8", "Alt")).tag(3)
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(width: 140)
            .disabled(!enabled.wrappedValue)
            Toggle(label, isOn: enabled)
                .labelsHidden()
                .toggleStyle(.switch)
                .fixedSize()
        }
    }
}

private extension View {
    @ViewBuilder
    func settingsFocusStyle() -> some View {
        if #available(macOS 14.0, *) {
            focusEffectDisabled()
        } else {
            self
        }
    }
}
