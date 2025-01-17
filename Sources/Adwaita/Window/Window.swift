//
//  Window.swift
//  Adwaita
//
//  Created by david-swift on 14.09.23.
//

// swiftlint:disable discouraged_optional_collection

import Foundation

/// A structure representing an application window type.
///
/// Note that multiple instances of a window can be opened at the same time.
public struct Window: WindowScene {

    /// The window's identifier.
    public var id: String
    /// The window's content.
    var content: (GTUIApplicationWindow) -> Body
    /// Whether an instance of the window type should be opened when the app is starting up.
    public var `open`: Int
    /// The identifier of the window's parent.
    public var parentID: String?
    /// The keyboard shortcuts.
    var shortcuts: [String: (GTUIApplicationWindow) -> Void] = [:]
    /// The keyboard shortcuts on the app level.
    public var appShortcuts: [String: (GTUIApp) -> Void] = [:]
    /// The default window size.
    var defaultSize: (Int, Int)?
    /// The window's title.
    var title: String?
    /// Whether the window is resizable.
    var resizable = true
    /// Whether the window is deletable.
    var deletable = true
    /// The signals for the importers and exporters.
    var signals: [Signal] = []

    /// Create a window type with a certain identifier and user interface.
    /// - Parameters:
    ///   - id: The identifier.
    ///   - open: The number of instances of the window type when the app is starting.
    ///   - content: The window's content.
    public init(id: String, `open`: Int = 1, @ViewBuilder content: @escaping (GTUIApplicationWindow) -> Body) {
        self.content = content
        self.id = id
        self.open = open
    }

    /// Get the storage for the window.
    /// - Parameter app: The application.
    /// - Returns: The storage.
    public func createWindow(app: GTUIApp) -> WindowStorage {
        let window = createGTUIWindow(app: app)
        let storage = getViewStorage(window: window)
        let windowStorage = WindowStorage(id: id, window: window, view: storage)
        window.observeHide {
            windowStorage.destroy = true
        }
        windowStorage.parentID = parentID
        return windowStorage
    }

    /// Get the window.
    /// - Parameter app: The application.
    /// - Returns: The window.
    func createGTUIWindow(app: GTUIApp) -> GTUIApplicationWindow {
        let window = GTUIApplicationWindow(app: app)
        updateAppShortcuts(app: app)
        window.show()
        return window
    }

    /// Get the storage of the content view.
    /// - Parameter window: The window.
    /// - Returns: The storage of the content of the window.
    func getViewStorage(window: GTUIApplicationWindow) -> ViewStorage {
        let content = content(window)
        let storage = content.widget(modifiers: []).container(modifiers: [])
        window.setChild(storage.pointer)
        window.setDefaultSize(width: defaultSize?.0, height: defaultSize?.1)
        setProperties(window: window)
        updateShortcuts(window: window)
        return storage
    }

    /// Update a window storage's content.
    /// - Parameters:
    ///     - storage: The storage to update.
    ///     - app: The GTUI app.
    ///     - force: Whether to force update all the views.
    public func update(_ storage: WindowStorage, app: GTUIApp, force: Bool) {
        if let window = storage.window as? GTUIApplicationWindow {
            let content = content(window)
            if let view = storage.view {
                content.widget(modifiers: []).updateStorage(view, modifiers: [], updateProperties: force)
            }
            setProperties(window: window)
            updateShortcuts(window: window)
            updateAppShortcuts(app: app)
        }
        for signal in signals where signal.update {
            Task {
                app.showWindow(signal.id.uuidString)
            }
        }
    }

    /// Set some general propreties of the window.
    /// - Parameter window: The window.
    func setProperties(window: GTUIApplicationWindow) {
        if let title {
            window.setTitle(title)
        }
        window.setResizability(resizable)
        window.setDeletability(deletable)
    }

    /// Add windows that overlay the last instance of this window if presented.
    /// - Parameter windows: The windows.
    /// - Returns: The new windows and this window.
    public func overlay(@SceneBuilder windows: () -> [WindowSceneGroup]) -> [WindowScene] {
        windows().windows().map { window in
            var newWindow = window
            newWindow.parentID = id
            return newWindow
        } + [self]
    }

    /// Add an importer file dialog to the window.
    /// - Parameters:
    ///     - signal: The signal for opening the dialog.
    ///     - initialFolder: The URL to the folder open when being opened.
    ///     - extensions: The accepted file extensions.
    ///     - folders: Whether folders are accepted.
    ///     - onOpen: Run this when a file for importing has been chosen.
    ///     - onClose: Run this when the user cancelled the action.
    public func fileImporter(
        _ signal: Signal,
        initialFolder: URL? = nil,
        extensions: [String]? = nil,
        onOpen: @escaping (URL) -> Void,
        onClose: @escaping () -> Void
    ) -> Scene {
        var newSelf = self
        newSelf.signals.append(signal)
        return newSelf
            .overlay {
                FileDialog(
                    importer: signal.id.uuidString,
                    initialFolder: initialFolder,
                    extensions: extensions,
                    onOpen: onOpen,
                    onClose: onClose
                )
            }
    }

    /// Add an exporter file dialog to the window.
    /// - Parameters:
    ///     - signal: The signal for opening the dialog.
    ///     - initialFolder: The URL to the folder open when being opened.
    ///     - initialName: The default file name.
    ///     - onSave: Run this when a path for exporting has been chosen.
    ///     - onClose: Run this when the user cancelled the action.
    public func fileExporter(
        _ signal: Signal,
        initialFolder: URL? = nil,
        initialName: String? = nil,
        onSave: @escaping (URL) -> Void,
        onClose: @escaping () -> Void
    ) -> Scene {
        var newSelf = self
        newSelf.signals.append(signal)
        return newSelf
            .overlay {
                FileDialog(
                    exporter: signal.id.uuidString,
                    initialFolder: initialFolder,
                    initialName: initialName,
                    onSave: onSave,
                    onClose: onClose
                )
            }
    }

    /// Add a keyboard shortcut.
    /// - Parameters:
    ///     - shortcut: The keyboard shortcut.
    ///     - action: The closure to execute when the keyboard shortcut is pressed.
    /// - Returns: The window.
    public func keyboardShortcut(_ shortcut: String, action: @escaping (GTUIApplicationWindow) -> Void) -> Self {
        var newSelf = self
        newSelf.shortcuts[shortcut] = action
        return newSelf
    }

    /// Update the keyboard shortcuts.
    /// - Parameter window: The application window.
    func updateShortcuts(window: GTUIApplicationWindow) {
        for shortcut in shortcuts {
            window.addKeyboardShortcut(shortcut.key, id: shortcut.key) { shortcut.value(window) }
        }
    }

    /// Add the shortcut "<Ctrl>w" which closes the window.
    /// - Returns: The window.
    public func closeShortcut() -> Self {
        keyboardShortcut("w".ctrl()) { $0.close() }
    }

    /// Set the window's default size.
    /// - Parameters:
    ///     - width: The window's width.
    ///     - height: The window's height.
    /// - Returns: The window.
    public func defaultSize(width: Int, height: Int) -> Self {
        var newSelf = self
        newSelf.defaultSize = (width, height)
        return newSelf
    }

    /// Set the window's title.
    /// - Parameter title: The title.
    /// - Returns: The window.
    public func title(_ title: String) -> Self {
        var newSelf = self
        newSelf.title = title
        return newSelf
    }

    /// Set whether the window is resizable.
    /// - Parameter resizable: The resizability.
    /// - Returns: The window.
    public func resizable(_ resizable: Bool) -> Self {
        var newSelf = self
        newSelf.resizable = resizable
        return newSelf
    }

    /// Set whether the window is deletable.
    /// - Parameter resizable: The deletability.
    /// - Returns: The window.
    public func deletable(_ deletable: Bool) -> Self {
        var newSelf = self
        newSelf.deletable = deletable
        return newSelf
    }

}

// swiftlint:enable discouraged_optional_collection
