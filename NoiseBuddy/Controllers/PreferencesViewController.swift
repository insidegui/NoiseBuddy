//
//  PreferencesViewController.swift
//  NoiseBuddy
//
//  Created by Guilherme Rambo on 13/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

class PreferencesViewController: NSViewController {

    @IBOutlet weak var launchAtLoginButton: NSButton!
    @IBOutlet weak var menuBarEnabledButton: NSButton!
    @IBOutlet weak var touchBarEnabledButton: NSButton!
    @IBOutlet weak var toggleKeyboardShortcutEnabledButton: NSButton!

    @IBOutlet weak var keyboardShortcutToggleModeButton: NSButton!

    var isListening = false {
        didSet {
                DispatchQueue.main.async { [weak self] in
                    self?.keyboardShortcutToggleModeButton.isHighlighted.toggle()
                }
            }
    }

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

    override func viewDidLoad() {
        super.viewDidLoad()
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return nil
        }
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
        toggleKeyboardShortcutEnabledButton.state = preferences.keyboardShortcutToggleEnabled ? .on : .off
        keyboardShortcutToggleModeButton.isEnabled = preferences.keyboardShortcutToggleEnabled
        keyboardShortcutToggleModeButton.title = preferences.keyboardShortcut?.title ?? "Record Shortcut"
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

    @IBAction func keyboardShortcutToggleEnabledAction(_ sender: NSButton) {
        preferences.keyboardShortcutToggleEnabled = sender.state == .on
        keyboardShortcutToggleModeButton.isEnabled = sender.state == .on ? true : false
    }
    
    @IBAction func toggleAirPodsProModeAction(_ sender: NSButton) {
        isListening = true
        preferences.keyboardShortcutPause = true
        view.window?.makeFirstResponder(nil)
    }

    @IBAction func openRepositoryWebsite(_ sender: ActionLabel) {
        let url = URL(string: "https://github.com/insidegui/NoiseBuddy")!
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func openAirBuddyWebsite(_ sender: ActionLabel) {
        let url = URL(string: "https://airbuddy.app")!
        NSWorkspace.shared.open(url)
    }
    
    func updateGlobalShortcut(_ event : NSEvent) {
        self.isListening = false
        
        if let characters = event.charactersIgnoringModifiers {
            updateKeybindButton(with: characters)
        }
    }
    
    func updateKeybindButton(with shortcut: String) {
        keyboardShortcutToggleModeButton.title = shortcut
    }
    
    override func keyDown(with event: NSEvent) {
        if isListening == false { return }
        defer {
            isListening = false
            preferences.keyboardShortcutPause = false
        }
        
        if Int(event.keyCode) == kVK_Escape { return }
    
        keyboardShortcutToggleModeButton.title = event.modifierFlags.description + event.charactersIgnoringModifiers!.description.uppercased()
        
        guard let key = event.charactersIgnoringModifiers?.description.uppercased() else { return }
        
        let newShortcut = KeyBoardShortcut(eventCode: UInt32(event.keyCode), modifier: event.modifierFlags.carbonFlags, title: event.modifierFlags.description + key)
        preferences.keyboardShortcut = newShortcut
  
    }
}
