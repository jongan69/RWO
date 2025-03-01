//
//  PriceFeed.swift
//  PriceFeed
//
//  Created by Jonathan Gan on 2/23/25.
//

import WidgetKit
import SwiftUI
import AppIntents

// Function to fetch data asynchronously
func fetchComplicationData(displayFormat: PriceDisplayOption) async -> String {
    guard let url = URL(string: "https://www.retardio.exposed/api/combined") else {
        return "Invalid URL"
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedData = try JSONDecoder().decode(RetardioResponse.self, from: data)

        switch displayFormat {
            // SOL Floor Price
        case .sol:
            return String(format: "%.2f SOL", decodedData.floorPrice)
            // USD Floor Price
        case .usd:
            return String(format: "$%.2f", decodedData.floorUsdValue)
            // Coin USD Price
        case .coin:
            return String(format: "$%.2f", decodedData.quoteUsdValue)
        case .floorChange24hr:
            // Use the 24-hour floor price percentage change
            let floorChangePercentage = decodedData.fpPctChg24hr // Assuming it's the 24hr change
            return String(format: "%.2f%%", floorChangePercentage)
        case .floorChange7d:
            // Use the 7-day floor price percentage change
            let floorChangePercentage = decodedData.fpPctChg7d // Assuming it's the 7d change
            return String(format: "%.2f%%", floorChangePercentage)
        case .both:
            // Display both floor price and floor price change (in percentage)
            return "\(decodedData.uiFloorFormatted) (\(String(format: "%.2f%%", decodedData.fpPctChg24hr)))"
        }
    } catch {
        return "Error: \(error.localizedDescription)"
    }
}



// Widget provider
struct RWOComplicationProvider: AppIntentTimelineProvider {
    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        return PriceDisplayOption.allCases.map { format in
            let intent = ConfigurationAppIntent()
            intent.displayFormat = format
            intent.refreshInterval = 10   // Default interval

            return AppIntentRecommendation(intent: intent, description: Text(format.rawValue))
        }
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            value: "--",
            configuration: ConfigurationAppIntent(
                displayFormat: IntentParameter(title: "Display Format", default: .both),
                refreshInterval: IntentParameter(title: "Refresh Interval", default: 10)
            )
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let latestData = await fetchComplicationData(displayFormat: configuration.displayFormat)
        return SimpleEntry(date: Date(), value: latestData, configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let latestData = await fetchComplicationData(displayFormat: configuration.displayFormat)
        let entry = SimpleEntry(date: Date(), value: latestData, configuration: configuration)
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: configuration.refreshInterval, to: Date()) ?? Date().addingTimeInterval(600)
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// Timeline entry struct
struct SimpleEntry: TimelineEntry {
    let date: Date
    let value: String
    let configuration: ConfigurationAppIntent
}

// Widget UI
struct RWOComplicationEntryView: View {
    var entry: RWOComplicationProvider.Entry

    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        GeometryReader { geometry in
            let gradient = getBackgroundGradient(price: entry.value)

            VStack {
                // Add a fallback if entry value is empty or invalid
                Text(entry.value.isEmpty ? "No Data" : entry.value)
                    .font(.system(size: getFontSize(for: geometry), weight: .bold))
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)  // Ensure it doesn't wrap if space is tight
                    .padding()
                    .cornerRadius(12)
                    .containerBackground(gradient, for: .widget) // Apply background to the top container section
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Ensure the Text is centered within the parent
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the parent frame is large enough
    }

    // Function to adjust font size based on widget size and geometry
    func getFontSize(for geometry: GeometryProxy) -> CGFloat {
        switch widgetFamily {
        case .accessoryCircular:
            // Adjust font size for smaller circular widgets
            return geometry.size.width > 40 ? 12 : 10
        case .accessoryInline:
            return geometry.size.width > 50 ? 14 : 12
        case .accessoryRectangular:
            return geometry.size.width > 60 ? 16 : 14
        case .accessoryCorner:
            return geometry.size.width > 70 ? 18 : 16
        default:
            return 14
        }
    }

    // Function to get the appropriate background gradient based on the price value
    func getBackgroundGradient(price: String) -> LinearGradient {
        // Regex to extract numeric value from the price string
        let priceRegex = try! NSRegularExpression(pattern: "-?\\d*\\.?\\d+", options: [])
        
        if let match = priceRegex.firstMatch(in: price, options: [], range: NSRange(location: 0, length: price.utf16.count)) {
            let priceSubstring = (price as NSString).substring(with: match.range)
            
            if let priceValue = Double(priceSubstring) {
                if priceValue > 0 {
                    return LinearGradient(gradient: Gradient(colors: [Color.green, Color.black]), startPoint: .top, endPoint: .bottom)
                } else {
                    return LinearGradient(gradient: Gradient(colors: [Color.red, Color.black]), startPoint: .top, endPoint: .bottom)
                }
            }
        }
        
        // Default gradient if we can't parse the price
        return LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]), startPoint: .top, endPoint: .bottom)
    }
}

// Widget definition
@main
struct RWOComplicationWidget: Widget {
    let kind: String = "RWOComplicationWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: RWOComplicationProvider()) { entry in
            RWOComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("RWO Complication")
        .description("Displays the latest Retardio price stats.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular,
            .accessoryCorner
        ])
        
    }
    
}

#Preview(as: .accessoryRectangular) {
    RWOComplicationWidget()
} timeline: {
    SimpleEntry(
        date: .now.addingTimeInterval(60),
        value: "8.9 SOL",
        configuration: ConfigurationAppIntent(
            displayFormat: IntentParameter(title: "Display Format", default: .sol),
            refreshInterval: IntentParameter(title: "Refresh Interval", default: 10)
        )
    )
}
