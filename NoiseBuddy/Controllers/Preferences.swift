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

    private let defaults: UserDefaults

    static let shared = Preferences()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func register() {
        defaults.register(defaults: [
            "listeningModes": [
                NCListeningMode.anc.rawValue,
                NCListeningMode.transparency.rawValue
            ]
        ])
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
