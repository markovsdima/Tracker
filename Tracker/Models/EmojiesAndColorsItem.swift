//
//  EmojiesAndColorsItem.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 03.04.2024.
//

import UIKit

struct EmojiesAndColorsItem: Hashable {
    let emoji: String?
    let color: UIColor?
    let category: Category
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(identifier)
    }
    
    static func emojiesAndColors() -> [EmojiesAndColorsItem] {
        return [
            EmojiesAndColorsItem(emoji: "🙂", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "😻", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🌺", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🐶", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "❤️", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "😱", color: nil, category: .emojies),
            
            EmojiesAndColorsItem(emoji: "😇", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "😡", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🥶", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🤔", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🙌", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🍔", color: nil, category: .emojies),
            
            EmojiesAndColorsItem(emoji: "🥦", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🏓", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🥇", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🎸", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🏝", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "😪", color: nil, category: .emojies),
            
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color1, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color2, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color3, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color4, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color5, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color6, category: .colors),
            
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color7, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color8, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color9, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color10, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color11, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color12, category: .colors),
            
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color13, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color14, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color15, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color16, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color17, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color18, category: .colors)
        ]
    }
}
