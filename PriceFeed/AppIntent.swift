//
//  AppIntent.swift
//  PriceFeed
//
//  Created by Jonathan Gan on 2/23/25.
//

import WidgetKit
import AppIntents

enum PriceDisplayOption: String, AppEnum {
    case sol = "SOL"
    case usd = "USD"
    case both = "Both"

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Price Display Format")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .sol: DisplayRepresentation(title: "SOL"),
            .usd: DisplayRepresentation(title: "USD"),
            .both: DisplayRepresentation(title: "Both (SOL & USD)")
        ]
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Price Feed Configuration" }
    static var description: IntentDescription { "Customize how the price is displayed in the complication." }

    @Parameter(title: "Display Format", default: .both)
    var displayFormat: PriceDisplayOption

    @Parameter(title: "Refresh Interval (Minutes)", default: 10)
    var refreshInterval: Int
}


