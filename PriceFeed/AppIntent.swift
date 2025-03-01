//
//  AppIntent.swift
//  PriceFeed
//
//  Created by Jonathan Gan on 2/23/25.
//

import WidgetKit
import AppIntents

enum PriceDisplayOption: String, AppEnum {
    case sol = "Floor Price in SOL"
    case usd = "Floor Price in USD"
    case coin = "Coin Price in USD"
    case floorChange24hr = "24hr Floor Change (%)"
    case floorChange7d = "7d Floor Change (%)"
    case both = "SOL & USD Price w/ 24hr % Change"

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Price Display Format")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .sol: DisplayRepresentation(title: "Floor Price in SOL"),
            .usd: DisplayRepresentation(title: "Floor Price in USD"),
            .coin: DisplayRepresentation(title: "Coin Price in USD"),
            .floorChange24hr: DisplayRepresentation(title: "24hr Floor Change (%)"),
            .floorChange7d: DisplayRepresentation(title: "7d Floor Change (%)"),
            .both: DisplayRepresentation(title: "SOL & USD Floor Price w/ 24hr % Change")
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


