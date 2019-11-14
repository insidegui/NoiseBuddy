//
//  AppDelegate.swift
//  NoiseBuddy
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Cocoa
import NoiseCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private lazy var listeningModeController: NCListeningModeStatusProvider = {
        if UserDefaults.standard.bool(forKey: "NBUseMockListeningModeController") {
            return MockListeningModeController()
        } else {
            return NCListeningModeController()
        }
    }()

    private lazy var touchBarController: NoiseControlTouchBarController = {
        NoiseControlTouchBarController(listeningModeController: self.listeningModeController)
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Preferences.shared.register()

        touchBarController.install()
    }

}

