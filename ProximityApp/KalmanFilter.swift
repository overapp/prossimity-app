//
//  KalmanFilter.swift
//  ProximityApp
//
//  Created by Lavinia Bertuzzi on 05/03/2020.
//  Copyright © 2020 OverApp. All rights reserved.
//

import UIKit

class KalmanFilter: NSObject {
    
    public var estimatedRSSI = 0.0 // Calculated rssi
    
    private var processNoise = 0.125 // Process noise
    private var measurementNoise = 0.8 // Measurement noise
    private var errorCovarianceRSSI = 0.0 // Calculated covariance
    
    private var isInitialized = false // Initialization flag
    
    init(first rssi: Double) {
        super.init()
        self.applyFilter(for: rssi)
    }

    public func applyFilter(for rssi: Double) {
        var priorRSSI = 0.0
        var kalmanGain = 0.0
        var priorErrorCovarianceRSSI = 0.0
        
        if (!isInitialized) {
            priorRSSI = rssi
            priorErrorCovarianceRSSI = 1.0
            isInitialized = true
        }
        else {
            priorRSSI = estimatedRSSI
            priorErrorCovarianceRSSI = errorCovarianceRSSI + processNoise
        }

        kalmanGain = priorErrorCovarianceRSSI / (priorErrorCovarianceRSSI + measurementNoise)
        estimatedRSSI = priorRSSI + (kalmanGain * (rssi - priorRSSI))
        errorCovarianceRSSI = (1 - kalmanGain) * priorErrorCovarianceRSSI
    }

}
