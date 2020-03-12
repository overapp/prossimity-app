//
//  ViewController.swift
//  ProssimityApp
//
//  Created by Lavinia Bertuzzi on 04/03/2020.
//  Copyright © 2020 OverApp. All rights reserved.
//

import UIKit
import AudioToolbox
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var centralManager: CBCentralManager!
    
    var timer = Timer()
    // Per ogni dispositivo dato il suo ID memorizzo il suo filtro (a se associato)
    var items: [String : KalmanFilter] = [:]
    
    //MARK: - ViewController LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //MARK: - Private Methods
    
    private func scheduledTimerWithTimeIntervalForScanning() {
        // Scheduling timer
        timer = Timer.scheduledTimer(
            timeInterval: 3,
            target: self,
            selector: #selector(self.scanForPeripherals),
            userInfo: nil,
            repeats: true)
    }
    
    //MARK: - Selectors
    @objc func scanForPeripherals() {
        // Scan / Re-scan
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
}

extension ViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("BLE has powered off")
            timer.invalidate()
            centralManager.stopScan()
        case .poweredOn:
            print("BLE is now powered on")
            self.scheduledTimerWithTimeIntervalForScanning()
        case .resetting: print("BLE is resetting")
        case .unauthorized: print("Unauthorized BLE state")
        case .unknown: print("Unknown BLE state")
        case .unsupported: print("This platform does not support BLE")
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // TODO: Print advertisingData
        // Filter discovered devices by name...
        if let name = peripheral.name {
            if let power = advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Double {
                // Truncate incoming RSSI
                let incomingRSSI = Double(truncating: RSSI)
                // Check if filter is already present for current peripheral
                guard let filter = items[name/*peripheral.identifier.uuidString*/] else {
                    // Init the KalmanFilter
                    items[name/*peripheral.identifier.uuidString*/] = KalmanFilter(first: incomingRSSI)
                    return
                }
                // Apply filter with new RSSI
                filter.applyFilter(for: incomingRSSI)
                
                /*
                 * Compute distance using the following formula:
                 *  10 ^ ((Measured Power – RSSI)/(10 * N))
                 */
                let distance = pow(10, ((power - filter.estimatedRSSI) / 40))
                
                if distance < 150.0 {
                    // Notify using vibration
                    // AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                }
                
                print("Found \"\(name)\" - RSSI: \(RSSI) - Distance is \(distance)")
                self.tableView.reloadData()
            }
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peripheral_cell", for: indexPath)
        
        cell.textLabel?.text = Array(items.keys)[indexPath.row]
        
        return cell
    }
    
}
