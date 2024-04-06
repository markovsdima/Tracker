//
//  Date+Extensions.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 05.04.2024.
//

import Foundation

extension Date {
    var onlyDate: Date? {
        get {
            let calender = Calendar.current
            var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = NSTimeZone.system

            return calender.date(from: dateComponents)
        }
    }
    
}
