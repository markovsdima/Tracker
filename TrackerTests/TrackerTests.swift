//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Dmitry Markovskiy on 11.04.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker


final class TrackerTests: XCTestCase {
    
    func testViewControllerLightAppearance() {
        let vc = TrackersViewController()
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testViewControllerDarkAppearance() {
        let vc = TrackersViewController()
        
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
    
}
