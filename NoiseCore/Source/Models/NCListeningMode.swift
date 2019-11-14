//
//  NCListeningMode.swift
//  NoiseCore
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Foundation

public enum NCListeningMode: String, CaseIterable {
    case normal = "AVOutputDeviceBluetoothListeningModeNormal"
    case anc = "AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"
    case transparency = "AVOutputDeviceBluetoothListeningModeAudioTransparency"
}

public extension NCListeningModeStatusProvider {

    var listeningMode: NCListeningMode {
        get {
            NCListeningMode(rawValue: _listeningMode) ?? .normal
        }
        set {
            _setListeningMode(newValue.rawValue)
        }
    }

    var availableListeningModes: [NCListeningMode] {
        _availableListeningModes.compactMap({ NCListeningMode(rawValue: $0) })
    }

}

public extension NCDevice {

    var listeningMode: NCListeningMode {
        NCListeningMode(rawValue: _listeningMode) ?? .normal
    }

    var availableListeningModes: [NCListeningMode] {
        _availableListeningModes.compactMap({ NCListeningMode(rawValue: $0) })
    }

}
