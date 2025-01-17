//
//  ToastOverlay+.swift
//  Adwaita
//
//  Created by david-swift on 21.01.24.
//

import CAdw
import Foundation

/// A wrapper around a view presenting toasts.
extension ToastOverlay {

    /// Initialize a toast overlay.
    /// - Parameters:
    ///     - title: The toast's title.
    ///     - signal: The signal for adding a toast.
    public init(_ title: String, signal: Signal) {
        appearFunctions.append { storage, _ in
            storage.fields["signal"] = signal
        }
        updateFunctions.append { storage, _, _ in
            if let signal = storage.fields["signal"] as? Signal, signal.update {
                let toast = ViewStorage(adw_toast_new(title))
                storage.fields[UUID().uuidString] = toast
                if let button = storage.fields["button"] as? String,
                let handler = storage.fields["handler"] as? () -> Void {
                    adw_toast_set_button_label(toast.pointer, button)
                    toast.connectSignal(name: "button-clicked", handler: handler)
                }
                adw_toast_overlay_add_toast(storage.pointer, toast.pointer)
            }
        }
    }

    /// Add an action button to the toast.
    /// - Parameters:
    ///     - button: The button's label.
    ///     - handler: The handler.
    /// - Returns: The toast overlay.
    public func action(button: String, handler: @escaping () -> Void) -> Self {
        var newSelf = self
        let action: (ViewStorage, [(View) -> View], Bool) -> Void = { storage, _, _ in
            storage.fields["button"] = button
            storage.fields["handler"] = handler
        }
        newSelf.updateFunctions.insert(action, at: 0)
        return newSelf
    }

}

extension View {

    /// Present a toast when the signal gets activated.
    /// - Parameters:
    ///     - title: The title of the toast.
    ///     - signal: The signal which activates the presentation of a toast.
    /// - Returns: A view.
    public func toast(_ title: String, signal: Signal) -> View {
        ToastOverlay(title, signal: signal)
            .child { self }
    }

    /// Present a toast with a button when the signal gets activated.
    /// - Parameters:
    ///     - title: The title of the toast.
    ///     - signal: The signal which activates the presentation of a toast.
    ///     - button: The button's label.
    ///     - handler: The handler for the button.
    /// - Returns: A view.
    public func toast(_ title: String, signal: Signal, button: String, handler: @escaping () -> Void) -> View {
        ToastOverlay(title, signal: signal)
            .child { self }
            .action(button: button, handler: handler)
    }

}
