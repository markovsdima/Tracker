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

enum WeekDay: Hashable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
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
