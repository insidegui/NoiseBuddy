//
//  NoiseControlTouchBarController.swift
//  NoiseBuddy
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Cocoa
import NoiseCore

fileprivate extension NSTouchBarItem.Identifier {
    static let noiseControl = NSTouchBarItem.Identifier("codes.rambo.NoiseBuddy")
}

final class NoiseControlTouchBarController: NSObject {

    let preferences: Preferences
    let listeningModeController: NCListeningModeStatusProvider
    let item: NSCustomTouchBarItem

    init(listeningModeController: NCListeningModeStatusProvider, preferences: Preferences)
    {
        self.listeningModeController = listeningModeController
        self.preferences = preferences

        let customItem = NSCustomTouchBarItem(identifier: .noiseControl)
        customItem.customizationLabel = "Listening Mode"

        self.item = customItem

        super.init()
    }

    private lazy var button: NSButton = {
        NSButton(image: NSImage(), target: self, action: #selector(tappedNoiseControlItem))
    }()

    func install() {
        item.view = button

        NSTouchBarItem.addSystemTrayItem(item)

        DFRSystemModalShowsCloseBoxWhenFrontMost(true)

        listeningModeController.outputDeviceDidChange = { [weak self] device in
            self?.handleDeviceDidChange(device)
        }

        listeningModeController.startListeningForUpdates()

        NotificationCenter.default.addObserver(forName: Preferences.didChangeNotification, object: preferences, queue: .main) { [weak self] _ in
            self?.reevaluateVisibility()
        }
    }

    private func shouldShow(for device: NCDevice?) -> Bool {
        guard let device = device else { return false }
        return device.supportsListeningModes && preferences.touchBarEnabled
    }

    private var currentDevice: NCDevice?

    private func handleDeviceDidChange(_ device: NCDevice?) {
        defer { reevaluateVisibility() }

        currentDevice = device

        guard let device = device else { return }

        handleListeningModeDidChange(device)
        
        device.listeningModeDidChange = { [weak self] inDevice in
            self?.handleListeningModeDidChange(inDevice)
        }
    }

    private func reevaluateVisibility() {
        DFRElementSetControlStripPresenceForIdentifier(.noiseControl, shouldShow(for: currentDevice))
    }

    private func handleListeningModeDidChange(_ device: NCDevice) {
        button.image = device.listeningMode.image
    }

    @objc private func tappedNoiseControlItem(_ sender: NSButton) {
        let nextMode = preferences.nextListeningMode(from: listeningModeController.listeningMode)

        listeningModeController.listeningMode = nextMode
    }

}

fileprivate extension Preferences {

    func nextListeningMode(from currentMode: NCListeningMode) -> NCListeningMode {
        let fallbackMode = listeningModes.first ?? currentMode

        guard let idx = listeningModes.lastIndex(of: currentMode) else { return fallbackMode }

        let nextIdx = idx + 1
        guard nextIdx < listeningModes.count else { return fallbackMode }

        return listeningModes[nextIdx]
    }

}

fileprivate extension NCListeningMode {
    var image: NSImage? {
        NSImage(named: NSImage.Name(rawValue))
    }
}

fileprivate extension NCDevice {
    var supportsListeningModes: Bool { availableListeningModes.count > 1 }
}
