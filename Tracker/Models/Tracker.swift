//
//  Tracker.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 14.02.2024.
//

import UIKit

struct Tracker: Hashable {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]?
    let trackerType: TrackerTypes
}

enum WeekDay: Int, Hashable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
}

enum TrackerTypes: String {
    case oneTimeEvent
    case regularEvent
    
    var name: String {
        switch self {
        case .oneTimeEvent:
            return "Новое нерегулярное событие"
        case .regularEvent:
            return "Новая привычка"
        }
    }
}

enum WeekDays: String {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}
