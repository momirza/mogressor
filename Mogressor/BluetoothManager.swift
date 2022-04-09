//
//  BluetoothManager.swift
//  Mogressor
//
//  Created by Mo Mirza on 09/04/2022.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var central: CBCentralManager!
    
    private let progressorCBUUID = CBUUID(string: "7E4E1701-1EA6-40C9-9DCC-13D34FFEAD57")
    private let dataPointCBUUID = CBUUID(string: "7e4e1702-1ea6-40c9-9dcc-13d34ffead57")
    private let controlPointCBUUID = CBUUID(string: "7e4e1703-1ea6-40c9-9dcc-13d34ffead57")

    private var controlCharacteristic: CBCharacteristic? = nil
    
    @Published var data = [Double]()
    var maxLoad: Double? { data.max() }
    @Published var connectedDevice: CBPeripheral? = nil
        
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
        central.delegate = self
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            scanForDevices()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if connectedDevice == nil {
            connectedDevice = peripheral
            central.connect(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard let services = peripheral.services else { return }

        for service in services {
            if service.uuid == progressorCBUUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == dataPointCBUUID {
                if characteristic.properties.contains(.notify) {
                  peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            if characteristic.uuid == controlPointCBUUID {
                peripheral.writeValue(Data([0x65]), for: characteristic, type: .withResponse)
                controlCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {

            let sub = value.subdata(in: Range(2...5))

            let value = sub.withUnsafeBytes {
                $0.load(as: Float32.self)
            }
            data.append(contentsOf: [max(0.001, round(Double(value) * 10 ) / 10)])
            
        }
    }
        
    func scanForDevices() {
        print("Scanning for devices")
        central.scanForPeripherals(withServices: [progressorCBUUID])
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.central.stopScan()
        }
    }
    
    func tare() {
        if let connectedDevice = connectedDevice, let controlCharacteristic = controlCharacteristic {
            connectedDevice.writeValue(Data([0x64]), for: controlCharacteristic, type: .withResponse)
            data = []
            connectedDevice.writeValue(Data([0x65]), for: controlCharacteristic, type: .withResponse)
        }
    }

}
