//
//  NoiseControlUIController.swift
//  NoiseBuddy
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Cocoa
import NoiseCore

class NoiseControlUIController: NSObject {

    let preferences: Preferences
    let listeningModeController: NCListeningModeStatusProvider

    init(listeningModeController: NCListeningModeStatusProvider, preferences: Preferences)
    {
        self.listeningModeController = listeningModeController
        self.preferences = preferences

        super.init()
    }

    func configureUI() {
        assertionFailure("Subclasses must override configureUI and not call super")
    }

    func install() {
        configureUI()
        
        listeningModeController.outputDeviceDidChange = { [weak self] device in
            self?.handleDeviceDidChange(device)
        }

        listeningModeController.startListeningForUpdates()
    }

    var isEnabled: Bool { fatalError("Subclasses must override isEnabled and not call super") }

    func shouldShow(for device: NCDevice?) -> Bool {
        guard let device = device else { return false }
        return device.supportsListeningModes && isEnabled
    }

    private(set) var currentDevice: NCDevice?

    private func handleDeviceDidChange(_ device: NCDevice?) {
        defer { reevaluateVisibility() }

        currentDevice = device

        guard let device = device else { return }

        handleListeningModeDidChange(device)

        device.listeningModeDidChange = { [weak self] inDevice in
            self?.handleListeningModeDidChange(inDevice)
        }
    }

    func reevaluateVisibility() {
        assertionFailure("Subclasses must override reevaluateVisibility and not call super")
    }

    func handleListeningModeDidChange(_ device: NCDevice) {
        assertionFailure("Subclasses must override handleListeningModeDidChange and not call super")
    }

    @objc func toggleNoiseControlMode(_ sender: Any) {
        let nextMode = preferences.nextListeningMode(from: listeningModeController.listeningMode)

        listeningModeController.listeningMode = nextMode
    }

}

extension Preferences {

    func nextListeningMode(from currentMode: NCListeningMode) -> NCListeningMode {
        let fallbackMode = listeningModes.first ?? currentMode

        guard let idx = listeningModes.lastIndex(of: currentMode) else { return fallbackMode }

        let nextIdx = idx + 1
        guard nextIdx < listeningModes.count else { return fallbackMode }

        return listeningModes[nextIdx]
    }

}

extension NCListeningMode {
    var touchBarImage: NSImage? { NSImage(named: NSImage.Name(rawValue)) }
    var menuBarImage: NSImage? { NSImage(named: NSImage.Name("\(rawValue)-menu")) }
}

extension NCDevice {
    var supportsListeningModes: Bool { availableListeningModes.count > 1 }
}
