//
//  MockListeningModeController.swift
//  NoiseBuddy
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Foundation
import NoiseCore

final class MockListeningModeController: NSObject, NCListeningModeStatusProvider {

    private var fakeUpdateTimer: Timer?

    private var fakeAirPodsPro: NCDevice {
        let dev = NCDevice()
        dev.identifier = "1"
        dev.name = "John's AirPods Pro"
        dev._availableListeningModes = NCListeningMode.allCases.map { $0.rawValue }
        dev._listeningMode = NCListeningMode.anc.rawValue
        return dev
    }

    private var fakeBeatsStudio: NCDevice {
        let dev = NCDevice()
        dev.identifier = "2"
        dev.name = "John's Beats Studio"
        dev._availableListeningModes = [NCListeningMode.normal.rawValue]
        dev._listeningMode = NCListeningMode.normal.rawValue
        return dev
    }

    private lazy var currentFakeDevice: NCDevice = {
        fakeAirPodsPro
    }()

    func startListeningForUpdates() {
        fakeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { _ in
            if self.currentFakeDevice.identifier == self.fakeAirPodsPro.identifier {
                self.currentFakeDevice = self.fakeBeatsStudio
            } else {
                self.currentFakeDevice = self.fakeAirPodsPro
            }

            self.outputDeviceDidChange(self.currentFakeDevice)
        })

        self.outputDeviceDidChange(self.currentFakeDevice)
    }

    var outputDeviceDidChange: (NCDevice?) -> Void = { _ in }

    var _availableListeningModes: [String] {
        currentFakeDevice._availableListeningModes
    }

    var _listeningMode: String {
        get {
            currentFakeDevice._listeningMode
        }
        set {
            _setListeningMode(newValue)
        }
    }

    func _setListeningMode(_ listeningMode: String) {
        currentFakeDevice._listeningMode = listeningMode
        self.outputDeviceDidChange(self.currentFakeDevice)
    }

}
