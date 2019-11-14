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

    private func makeListeningModeController() -> NCListeningModeStatusProvider {
        if UserDefaults.standard.bool(forKey: "NBUseMockListeningModeController") {
            return MockListeningModeController()
        } else {
            return NCListeningModeController()
        }
    }

    private lazy var preferences = Preferences()

    private lazy var touchBarController: TouchBarUIController = {
        TouchBarUIController(
            listeningModeController: self.makeListeningModeController(),
            preferences: self.preferences
        )
    }()

    private lazy var menuBarController: MenuBarUIController = {
        MenuBarUIController(
            listeningModeController: self.makeListeningModeController(),
            preferences: self.preferences
        )
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        preferences.register()

        touchBarController.install()
        menuBarController.install()

        if !preferences.hasLaunchedBefore || UserDefaults.standard.bool(forKey: "NBShowPreferences") {
            preferences.hasLaunchedBefore = true
            showPreferences(self)
        }
    }

    private lazy var preferencesController: NSWindowController = {
        PreferencesViewController.instantiate(with: self.preferences).0
    }()

    @IBAction func showPreferences(_ sender: Any) {
        preferencesController.showWindow(sender)
        NSApp.activate(ignoringOtherApps: false)
    }

    private var activationCount = 0

    func applicationDidBecomeActive(_ notification: Notification) {
        if activationCount > 1 { showPreferences(self) }

        activationCount += 1
    }

}

