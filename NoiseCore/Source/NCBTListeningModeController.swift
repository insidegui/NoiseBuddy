//
//  NCBTListeningModeController.swift
//  NoiseCore
//
//  Created by Guilherme Rambo on 14/11/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import Cocoa
import IOBluetooth
import os.log

public final class NCBTListeningModeController: NSObject, NCListeningModeStatusProvider {

    private let log = OSLog(subsystem: "codes.rambo.NoiseCore", category: "NCBTListeningModeController")

    private var airPodsProDevices: [IOBluetoothDevice] {
        IOBluetoothDevice.pairedDevices()?
                         .compactMap { $0 as? IOBluetoothDevice }
                         .filter { $0.isANCSupported() } ?? []
    }

    private var currentDevice: IOBluetoothDevice? {
        airPodsProDevices.first
    }

    private var connectionNotification: IOBluetoothUserNotification?
    
    public func startListeningForUpdates() {
        guard connectionNotification == nil else { return }

        connectionNotification = IOBluetoothDevice.register(forConnectNotifications: self, selector: #selector(connectionNotificationReceived))

        sendDeviceDidChange()
    }

    private func sendDeviceDidChange() {
        DispatchQueue.main.async {
            guard let currentDevice = self.currentDevice else { return }

            let device = NCDevice(btDevice: currentDevice)
            self.outputDeviceDidChange(device)
        }
    }

    public var outputDeviceDidChange: (NCDevice?) -> Void = { _ in }

    public var _availableListeningModes: [String] = []

    public var _listeningMode: String = NCListeningMode.normal.rawValue

    public func _setListeningMode(_ listeningMode: String) {
        guard let device = currentDevice else {
            os_log("AirPods Pro device not found", log: self.log, type: .error)
            return
        }

        let mode = UInt8(listeningModeName: listeningMode)

        os_log("Setting listening mode on %@ to %d", log: self.log, type: .debug, device.name ?? "", mode)

        device.listeningMode = mode

        _listeningMode = listeningMode
    }

    @objc private func connectionNotificationReceived(_ sender: Any) {
        os_log("%{public}@", log: log, type: .debug, #function)

        guard let device = currentDevice else {
            _availableListeningModes = []
            return
        }

        os_log("Supported device found: %@", log: self.log, type: .debug, String(describing: device))

        _availableListeningModes = NCListeningMode.allCases.map { $0.rawValue }

        sendDeviceDidChange()
    }

    deinit {
        connectionNotification?.unregister()
    }

}

extension UInt8 {
    init(listeningModeName: String) {
        switch listeningModeName {
        case NCListeningMode.anc.rawValue: self = 2
        case NCListeningMode.transparency.rawValue: self = 3
        default: self = 1
        }
    }
}

extension String {
    init(listeningModeCode: UInt8) {
        switch listeningModeCode {
        case 2: self = NCListeningMode.anc.rawValue
        case 3: self = NCListeningMode.transparency.rawValue
        default: self = NCListeningMode.normal.rawValue
        }
    }
}

extension NCDevice {
    convenience init(btDevice: IOBluetoothDevice) {
        self.init()

        self.identifier = btDevice.addressString ?? ""
        self.name = btDevice.name ?? ""
        self._listeningMode = String(listeningModeCode: btDevice.listeningMode)
        self._availableListeningModes = NCListeningMode.allCases.map { $0.rawValue }
    }
}
