//
//  LocationProvider.swift
//  Ramble
//
//  Created by Sam Jones on 5/17/24.
//

import Foundation
import SCSDKCameraKit
import CoreMotion

class MotionDataProvider: NSObject, DeviceMotionDataProvider {
    var deviceMotion: CMDeviceMotion?
    let motionManager = CMMotionManager()
    
    override init() {
        
        super.init()
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] (motion, error) in
             guard let self = self else { return }
             if let motion = motion {
                 self.deviceMotion = motion
             } else if let error = error {
                 print("Device motion update error: \(error.localizedDescription)")
             }
         }
    }
    
   
    func startUpdating(with parameters: DeviceMotionParameters) {
            let requiresCompassAlignment = parameters.requiresCompassAlignment
            // Configure motion manager based on parameters
            if requiresCompassAlignment {
                // Set specific configurations if needed
                motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // Update rate: 60 Hz
            }
            // Ensure motion updates are started
            if !motionManager.isDeviceMotionActive {
                motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] (motion, error) in
                    guard let self = self else { return }
                    if let motion = motion {
                        self.deviceMotion = motion
                    } else if let error = error {
                        print("Device motion update error: \(error.localizedDescription)")
                    }
                }
            }
        }
    
    func stopUpdating() {
        // Stop device motion updates
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
     
}
