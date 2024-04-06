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

enum WeekDay: Int, Hashable, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    static func convertScheduleToString(_ weekDays: [WeekDay]?) -> String? {
        guard let weekDays else { return nil }
        var scheduleString = ""
        for day in weekDays {
            scheduleString.append(contentsOf: "\(day.rawValue),")
        }
        
        return scheduleString
    }
    
    static func getScheduleFromString(daysString: String) -> [WeekDay] {
        var schedule = [WeekDay]()
        let weekDaysStringArray = daysString.split(separator: ",")
        for index in weekDaysStringArray {
            if let value = Int(index) {
                guard let weekDay = WeekDay(rawValue: value) else { return schedule }
                schedule.append(weekDay)
            }
        }
        
        return schedule
    }
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
    
    static func convertTrackerTypeToString(trackerType: TrackerTypes) -> String {
        if trackerType == .oneTimeEvent {
            return "1"
        } else {
            return "7"
        }
    }
    
    static func getTrackerTypeFromString(string: String) -> TrackerTypes {
        if string == "1" {
            return TrackerTypes.oneTimeEvent
        } else {
            return TrackerTypes.regularEvent
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
