//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 07.04.2024.
//

import Foundation

typealias Binding<T> = (T) -> Void

protocol CategoriesViewModelDelegate: AnyObject {
    func selectCategory(title: String?)
}

final class CategoriesViewModel {
    
    // MARK: - Properties
    weak var delegate: CategoriesViewModelDelegate?
    
    private let trackerCategoryStore = TrackerCategoryStore.shared
    
    private var trackerCategories: [TrackerCategory] = [] {
        didSet {
            reloadNames()
        }
    }
    
    private(set) var trackerCategoriesNames: [String] = [] {
        didSet {
            trackerCategoriesNamesBinding?(trackerCategoriesNames)
        }
    }
    
    var trackerCategoriesBinding: Binding<[TrackerCategory]>?
    var trackerCategoriesNamesBinding: Binding<[String]>?
    
    
    // MARK: - Initializers
    init() {
        trackerCategories = loadCategories()
        reloadNames()
        trackerCategoryStore.delegate = self
    }
    
    // MARK: Public Methods
    func addNewCategory(name: String) {
        do {
            try trackerCategoryStore.addCategory(title: name)
            
        } catch TrackerCategoryStoreError.categoryExist {
            print("Такая категория уже есть")
            // TODO: notificate in ui
        } catch {
            print("Неизвестная ошибка: \(error)")
        }
    }
    
    func didSelectCategory(with title: String) {
        delegate?.selectCategory(title: title)
    }
    
    // MARK: - Private Methods
    private func reloadNames() {
        trackerCategoriesNames = []
        for category in trackerCategories {
            trackerCategoriesNames.append(category.title)
        }
    }
    
    private func loadCategories() -> [TrackerCategory] {
        do {
            trackerCategories = try trackerCategoryStore.fetchCategories()
            
            return trackerCategories
        } catch {
            print("Error: \(error) while loading categories")
            return []
        }
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didChangeData(in store: TrackerCategoryStore) {
        self.trackerCategories = loadCategories()
    }
}
