//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 11.04.2024.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static let shared = AnalyticsService()
    private init() { }
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "0e2e850b-affc-4263-b401-daeb22d6b49e") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
