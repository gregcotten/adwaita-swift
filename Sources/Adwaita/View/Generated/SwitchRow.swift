//
//  SwitchRow.swift
//  Adwaita
//
//  Created by auto-generation on 17.02.24.
//

import CAdw
import LevenshteinTransformations

/// A [class@Gtk.ListBoxRow] used to represent two states.
/// 
/// <picture><source srcset="switch-row-dark.png" media="(prefers-color-scheme: dark)"><img src="switch-row.png" alt="switch-row"></picture>
/// 
/// The `AdwSwitchRow` widget contains a [class@Gtk.Switch] that allows the user
/// to select between two states: "on" or "off". When activated, the row will
/// invert its active state.
/// 
/// The user can control the switch by activating the row or by dragging on the
/// switch handle.
/// 
/// See [class@Gtk.Switch] for details.
/// 
/// Example of an `AdwSwitchRow` UI definition:
/// ```xml
/// <object class="AdwSwitchRow"><property name="title" translatable="yes">Switch Row</property><signal name="notify::active" handler="switch_row_notify_active_cb"/></object>
/// ```
/// 
/// The [property@SwitchRow:active] property should be connected to in order to
/// monitor changes to the active state.
public struct SwitchRow: Widget {

    /// Additional update functions for type extensions.
    var updateFunctions: [(ViewStorage, [(View) -> View], Bool) -> Void] = []
    /// Additional appear functions for type extensions.
    var appearFunctions: [(ViewStorage, [(View) -> View]) -> Void] = []

    /// The widget to activate when the row is activated.
    /// 
    /// The row can be activated either by clicking on it, calling
    /// [method@ActionRow.activate], or via mnemonics in the title.
    /// See the [property@PreferencesRow:use-underline] property to enable
    /// mnemonics.
    /// 
    /// The target widget will be activated by emitting the
    /// [signal@Gtk.Widget::mnemonic-activate] signal on it.
    var activatableWidget:  (() -> Body)?
    /// Whether the switch row is in the "on" or "off" position.
    var active: Binding<Bool>?
    /// The icon name for this row.
    var iconName: String?
    /// The subtitle for this row.
    /// 
    /// The subtitle is interpreted as Pango markup unless
    /// [property@PreferencesRow:use-markup] is set to `FALSE`.
    var subtitle: String?
    /// The number of lines at the end of which the subtitle label will be
    /// ellipsized.
    /// 
    /// If the value is 0, the number of lines won't be limited.
    var subtitleLines: Int?
    /// Whether the user can copy the subtitle from the label.
    /// 
    /// See also [property@Gtk.Label:selectable].
    var subtitleSelectable: Bool?
    /// The title of the preference represented by this row.
    /// 
    /// The title is interpreted as Pango markup unless
    /// [property@PreferencesRow:use-markup] is set to `FALSE`.
    var title: String?
    /// The number of lines at the end of which the title label will be ellipsized.
    /// 
    /// If the value is 0, the number of lines won't be limited.
    var titleLines: Int?
    /// Whether the user can copy the title from the label.
    /// 
    /// See also [property@Gtk.Label:selectable].
    var titleSelectable: Bool?
    /// Whether to use Pango markup for the title label.
    /// 
    /// Subclasses may also use it for other labels, such as subtitle.
    /// 
    /// See also [func@Pango.parse_markup].
    var useMarkup: Bool?
    /// Whether an embedded underline in the title indicates a mnemonic.
    var useUnderline: Bool?
    /// This signal is emitted after the row has been activated.
    var activated: (() -> Void)?
    /// The body for the widget "suffix".
    var suffix: () -> Body = { [] }
    /// The body for the widget "prefix".
    var prefix: () -> Body = { [] }
    /// The application.
    var app: GTUIApp?
    /// The window.
    var window: GTUIApplicationWindow?

    /// Initialize `SwitchRow`.
    public init() {
    }

    /// Get the widget's view storage.
    /// - Parameter modifiers: The view modifiers.
    /// - Returns: The view storage.
    public func container(modifiers: [(View) -> View]) -> ViewStorage {
        let storage = ViewStorage(adw_switch_row_new()?.opaque())
        update(storage, modifiers: modifiers, updateProperties: true)
        if let activatableWidgetStorage = activatableWidget?().widget(modifiers: modifiers).storage(modifiers: modifiers) {
            storage.content["activatableWidget"] = [activatableWidgetStorage]
            adw_action_row_set_activatable_widget(storage.pointer?.cast(), activatableWidgetStorage.pointer?.cast())
        }

        var suffixStorage: [ViewStorage] = []
        for view in suffix() {
            suffixStorage.append(view.storage(modifiers: modifiers))
            adw_action_row_add_suffix(storage.pointer?.cast(), suffixStorage.last?.pointer?.cast())
        }
        storage.content["suffix"] = suffixStorage
        var prefixStorage: [ViewStorage] = []
        for view in prefix() {
            prefixStorage.append(view.storage(modifiers: modifiers))
            adw_action_row_add_prefix(storage.pointer?.cast(), prefixStorage.last?.pointer?.cast())
        }
        storage.content["prefix"] = prefixStorage
        for function in appearFunctions {
            function(storage, modifiers)
        }
        return storage
    }

    /// Update the widget's view storage.
    /// - Parameters:
    ///     - storage: The view storage.
    ///     - modifiers: The view modifiers.
    ///     - updateProperties: Whether to update the view's properties.
    public func update(_ storage: ViewStorage, modifiers: [(View) -> View], updateProperties: Bool) {
        if let activated {
            storage.connectSignal(name: "activated", argCount: 0) {
                activated()
            }
        }
        storage.modify { widget in

        storage.notify(name: "active") {
            let newValue = adw_switch_row_get_active(storage.pointer) != 0
if let active, newValue != active.wrappedValue {
    active.wrappedValue = newValue
}
        }
            if let widget = storage.content["activatableWidget"]?.first {
                activatableWidget?().widget(modifiers: modifiers).update(widget, modifiers: modifiers, updateProperties: updateProperties)
            }
            if let active, updateProperties, (adw_switch_row_get_active(storage.pointer) != 0) != active.wrappedValue {
                adw_switch_row_set_active(storage.pointer, active.wrappedValue.cBool)
            }
            if let iconName, updateProperties {
                adw_action_row_set_icon_name(widget?.cast(), iconName)
            }
            if let subtitle, updateProperties {
                adw_action_row_set_subtitle(widget?.cast(), subtitle)
            }
            if let subtitleLines, updateProperties {
                adw_action_row_set_subtitle_lines(widget?.cast(), subtitleLines.cInt)
            }
            if let subtitleSelectable, updateProperties {
                adw_action_row_set_subtitle_selectable(widget?.cast(), subtitleSelectable.cBool)
            }
            if let title, updateProperties {
                adw_preferences_row_set_title(widget?.cast(), title)
            }
            if let titleLines, updateProperties {
                adw_action_row_set_title_lines(widget?.cast(), titleLines.cInt)
            }
            if let titleSelectable, updateProperties {
                adw_preferences_row_set_title_selectable(widget?.cast(), titleSelectable.cBool)
            }
            if let useMarkup, updateProperties {
                adw_preferences_row_set_use_markup(widget?.cast(), useMarkup.cBool)
            }
            if let useUnderline, updateProperties {
                adw_preferences_row_set_use_underline(widget?.cast(), useUnderline.cBool)
            }


        }
        for function in updateFunctions {
            function(storage, modifiers, updateProperties)
        }
    }

    /// The widget to activate when the row is activated.
    /// 
    /// The row can be activated either by clicking on it, calling
    /// [method@ActionRow.activate], or via mnemonics in the title.
    /// See the [property@PreferencesRow:use-underline] property to enable
    /// mnemonics.
    /// 
    /// The target widget will be activated by emitting the
    /// [signal@Gtk.Widget::mnemonic-activate] signal on it.
    public func activatableWidget(@ViewBuilder _ activatableWidget: @escaping (() -> Body)) -> Self {
        var newSelf = self
        newSelf.activatableWidget = activatableWidget
        
        return newSelf
    }

    /// Whether the switch row is in the "on" or "off" position.
    public func active(_ active: Binding<Bool>?) -> Self {
        var newSelf = self
        newSelf.active = active
        
        return newSelf
    }

    /// The icon name for this row.
    public func iconName(_ iconName: String?) -> Self {
        var newSelf = self
        newSelf.iconName = iconName
        
        return newSelf
    }

    /// The subtitle for this row.
    /// 
    /// The subtitle is interpreted as Pango markup unless
    /// [property@PreferencesRow:use-markup] is set to `FALSE`.
    public func subtitle(_ subtitle: String?) -> Self {
        var newSelf = self
        newSelf.subtitle = subtitle
        
        return newSelf
    }

    /// The number of lines at the end of which the subtitle label will be
    /// ellipsized.
    /// 
    /// If the value is 0, the number of lines won't be limited.
    public func subtitleLines(_ subtitleLines: Int?) -> Self {
        var newSelf = self
        newSelf.subtitleLines = subtitleLines
        
        return newSelf
    }

    /// Whether the user can copy the subtitle from the label.
    /// 
    /// See also [property@Gtk.Label:selectable].
    public func subtitleSelectable(_ subtitleSelectable: Bool? = true) -> Self {
        var newSelf = self
        newSelf.subtitleSelectable = subtitleSelectable
        
        return newSelf
    }

    /// The title of the preference represented by this row.
    /// 
    /// The title is interpreted as Pango markup unless
    /// [property@PreferencesRow:use-markup] is set to `FALSE`.
    public func title(_ title: String?) -> Self {
        var newSelf = self
        newSelf.title = title
        
        return newSelf
    }

    /// The number of lines at the end of which the title label will be ellipsized.
    /// 
    /// If the value is 0, the number of lines won't be limited.
    public func titleLines(_ titleLines: Int?) -> Self {
        var newSelf = self
        newSelf.titleLines = titleLines
        
        return newSelf
    }

    /// Whether the user can copy the title from the label.
    /// 
    /// See also [property@Gtk.Label:selectable].
    public func titleSelectable(_ titleSelectable: Bool? = true) -> Self {
        var newSelf = self
        newSelf.titleSelectable = titleSelectable
        
        return newSelf
    }

    /// Whether to use Pango markup for the title label.
    /// 
    /// Subclasses may also use it for other labels, such as subtitle.
    /// 
    /// See also [func@Pango.parse_markup].
    public func useMarkup(_ useMarkup: Bool? = true) -> Self {
        var newSelf = self
        newSelf.useMarkup = useMarkup
        
        return newSelf
    }

    /// Whether an embedded underline in the title indicates a mnemonic.
    public func useUnderline(_ useUnderline: Bool? = true) -> Self {
        var newSelf = self
        newSelf.useUnderline = useUnderline
        
        return newSelf
    }

    /// This signal is emitted after the row has been activated.
    public func activated(_ activated: @escaping () -> Void) -> Self {
        var newSelf = self
        newSelf.activated = activated
        return newSelf
    }

    /// Set the body for "suffix".
    /// - Parameter body: The body.
    /// - Returns: The widget.
    public func suffix(@ViewBuilder _ body: @escaping () -> Body) -> Self {
        var newSelf = self
        newSelf.suffix = body
        return newSelf
    }
    /// Set the body for "prefix".
    /// - Parameter body: The body.
    /// - Returns: The widget.
    public func prefix(@ViewBuilder _ body: @escaping () -> Body) -> Self {
        var newSelf = self
        newSelf.prefix = body
        return newSelf
    }
}
