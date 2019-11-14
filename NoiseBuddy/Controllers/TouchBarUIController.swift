//
//  TouchBarUIController.swift
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

final class TouchBarUIController: NoiseControlUIController {

    private lazy var item: NSCustomTouchBarItem = {
        let i = NSCustomTouchBarItem(identifier: .noiseControl)
        i.customizationLabel = "Listening Mode"
        return i
    }()

    private lazy var button: NSButton = {
        NSButton(image: NSImage(), target: self, action: #selector(toggleNoiseControlMode))
    }()

    override var isEnabled: Bool { preferences.touchBarEnabled }

    override func configureUI() {
        item.view = button

        NSTouchBarItem.addSystemTrayItem(item)

        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
    }

    override func reevaluateVisibility() {
        DFRElementSetControlStripPresenceForIdentifier(.noiseControl, shouldShow(for: currentDevice))
    }

    override func toggleNoiseControlMode(_ sender: Any) {
        let nextMode = preferences.nextListeningMode(from: listeningModeController.listeningMode)

        listeningModeController.listeningMode = nextMode

        button.image = nextMode.touchBarImage
    }

    override func handleListeningModeDidChange(_ device: NCDevice) {
        button.image = device.listeningMode.touchBarImage
    }

}

