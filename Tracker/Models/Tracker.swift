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


struct WeekDay: Hashable {
    
}

enum TrackerTypes: String {
    case oneTimeEvent
    case regularEvent
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
