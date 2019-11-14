//
//  PreferencesViewController.swift
//  NoiseBuddy
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    @IBOutlet weak var launchAtLoginButton: NSButton!
    @IBOutlet weak var menuBarEnabledButton: NSButton!
    @IBOutlet weak var touchBarEnabledButton: NSButton!

    private var preferences: Preferences!

    static func instantiate(with preferences: Preferences) -> (NSWindowController, PreferencesViewController) {
        let sb = NSStoryboard(name: NSStoryboard.Name("Preferences"), bundle: nil)
        guard let controller = sb.instantiateInitialController() as? PreferencesViewController else {
            fatalError("Corrupted storyboard")
        }
        controller.preferences = preferences

        let window = NSWindow(contentRect: .zero, styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.contentViewController = controller
        window.title = "NoiseBuddy Settings"
        let windowController = NSWindowController(window: window)

        window.center()

        return (windowController, controller)
    }

    private var isDFRAvailable: Bool {
        NSFunctionRow.isDynamicFunctionRowAvailable() && !UserDefaults.standard.bool(forKey: "NBSimulateDFRNotAvailable")
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        touchBarEnabledButton.isHidden = !isDFRAvailable
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        launchAtLoginButton.state = preferences.launchAtLoginEnabled ? .on : .off
        menuBarEnabledButton.state = preferences.menuBarEnabled ? .on : .off
        touchBarEnabledButton.state = preferences.touchBarEnabled ? .on : .off
    }

    @IBAction func launchAtLoginAction(_ sender: NSButton) {
        preferences.launchAtLoginEnabled = sender.state == .on
    }

    @IBAction func menuBarEnabledAction(_ sender: NSButton) {
        preferences.menuBarEnabled = sender.state == .on
    }

    @IBAction func touchBarEnabledAction(_ sender: NSButton) {
        preferences.touchBarEnabled = sender.state == .on
    }

    @IBAction func openRepositoryWebsite(_ sender: ActionLabel) {
        let url = URL(string: "https://github.com/insidegui/NoiseBuddy")!
        NSWorkspace.shared.open(url)
    }

    @IBAction func openAirBuddyWebsite(_ sender: ActionLabel) {
        let url = URL(string: "https://airbuddy.app")!
        NSWorkspace.shared.open(url)
    }

}
