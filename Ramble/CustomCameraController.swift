//
//  CameraKitViewController.swift
//  Ramble
//
//  Created by Sam Jones on 5/17/24.
//

import Foundation
import SCSDKCameraKit
import SCSDKCameraKitReferenceUI
import SwiftUI
import Combine

class CustomCameraController: CameraController {
    
    override func configureDataProvider() -> DataProviderComponent {
         DataProviderComponent(
            deviceMotion: nil, userData: nil, lensHint: nil, location: LocationProvider()
        )
    }
}
