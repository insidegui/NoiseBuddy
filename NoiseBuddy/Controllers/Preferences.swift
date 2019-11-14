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
            "touchBarEnabled": true
        ])

        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: defaults, queue: .main) { [weak self] _ in
            NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
        }
    }

    var menuBarEnabled: Bool {
        get { defaults.bool(forKey: #function) }
        set { defaults.set(newValue, forKey: #function) }
    }

    var touchBarEnabled: Bool {
        get { defaults.bool(forKey: #function) }
        set { defaults.set(newValue, forKey: #function) }
    }

    var listeningModes: [NCListeningMode] {
        get {
            let rawValues = defaults.array(forKey: #function) as? [String]
            return rawValues?.compactMap({ NCListeningMode(rawValue: $0) }) ?? []
        }
        set {
            defaults.set(newValue, forKey: #function)
        }
    }

}
