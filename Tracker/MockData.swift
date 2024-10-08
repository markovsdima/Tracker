//
//  MockData.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 06.03.2024.
//

import Foundation
import UIKit

final class MockData {
    
    static let shared = MockData()
    
    static let didChangeNotification = Notification.Name("CategoriesDidChange")
    
    
    
    var mockCategories: [TrackerCategory] = [
        TrackerCategory(
            title: "Космос",
            trackers: [
                Tracker(
                    id: UUID(uuidString: "1307ebcb-8414-4660-855f-8296bfb65cac")!,
                    title: "Полет в стратосферу",
                    color: .ypGreen,
                    emoji: "🌏",
                    schedule: [.monday],
                    trackerType: .oneTimeEvent, pin: false
                ),
                Tracker(
                    id: UUID(uuidString: "3325cfd0-3e72-49ad-8d66-48f2d9b6ca77")!,
                    title: "Высадка на луне",
                    color: .ypOrange,
                    emoji: "🌒",
                    schedule: [.sunday, .thursday, .friday],
                    trackerType: .oneTimeEvent, pin: false
                )
            ]
        ),
        TrackerCategory(
            title: "Планета",
            trackers: [
                Tracker(
                    id: UUID(uuidString: "0b1812e3-36bc-4345-b816-a35372cba024")!,
                    title: "Снежный человек, начало",
                    color: .ypGray,
                    emoji: "☃️",
                    schedule: [.wednesday],
                    trackerType: .oneTimeEvent, pin: false
                ),
                Tracker(
                    id: UUID(uuidString: "78c2a018-b10a-4a45-af80-ed55e8de9de2")!,
                    title: "Поиск Атлантиды",
                    color: .ypGray,
                    emoji: "🧊",
                    schedule: nil,
                    trackerType: .oneTimeEvent, pin: false
                )
            ]
        ),
        TrackerCategory(
            title: "Empty",
            trackers: []
        )
    ]
    
    var mockCompletedTrackers: Set<TrackerRecord> = []
    
    // MARK: - Initializers
    private init() {}
    
}
