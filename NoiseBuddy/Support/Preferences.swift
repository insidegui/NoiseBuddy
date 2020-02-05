//
//  Preferences.swift
//  NoiseBuddy
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Foundation
import NoiseCore

final class Preferences {

    static let didChangeNotification = Notification.Name("codes.rambo.NoiseBuddy.PrefsChanged")

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func register() {
        defaults.register(defaults: [
            "listeningModes": [
                NCListeningMode.anc.rawValue,
                NCListeningMode.transparency.rawValue
            ],
            "menuBarEnabled": true,
            "touchBarEnabled": true,
            "keyboardShortcutToggleEnabled": false,
            "keyboardShortcutPause": false
        ])
    }

    private func didChange() {
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }

    var hasLaunchedBefore: Bool {
        get { defaults.bool(forKey: #function) }
        set { defaults.set(newValue, forKey: #function) }
    }

    var menuBarEnabled: Bool {
        get { defaults.bool(forKey: #function) }
        set {
            defaults.set(newValue, forKey: #function)
            didChange()
        }
    }

    var touchBarEnabled: Bool {
        get { defaults.bool(forKey: #function) }
        set {
            defaults.set(newValue, forKey: #function)
            didChange()
        }
    }
    
    var keyboardShortcutToggleEnabled: Bool {
        get { defaults.bool(forKey: #function) }
        set {
            defaults.set(newValue, forKey: #function)
            didChange()
        }
    }
    
    var keyboardShortcutPause: Bool {
        get { defaults.bool(forKey: #function) }
        set {
            defaults.set(newValue, forKey: #function)
            didChange()
        }
    }
    
    var keyboardShortcut: KeyBoardShortcut? {
        get { defaults.codable(forKey: #function) }
        set {
            defaults.setEncode(newValue, forKey: #function)
            didChange()
        }
    }

    private var appURL: URL { Bundle.main.bundleURL }

    var launchAtLoginEnabled: Bool {
        get { SharedFileList.sessionLoginItems().containsItem(appURL) }
        set {
            if newValue {
                SharedFileList.sessionLoginItems().addItem(appURL)
            } else {
                SharedFileList.sessionLoginItems().removeItem(appURL)
            }

            didChange()
        }
    }

    var listeningModes: [NCListeningMode] {
        get {
            let rawValues = defaults.array(forKey: #function) as? [String]
            return rawValues?.compactMap({ NCListeningMode(rawValue: $0) }) ?? []
        }
        set {
            defaults.set(newValue, forKey: #function)

            didChange()
        }
    }

}
