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
        case .sol:
            return String(format: "%.2f SOL", decodedData.floorPrice)
        case .usd:
            return String(format: "$%.2f", decodedData.floorUsdValue)
        case .both:
            return decodedData.uiFloorFormatted
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
            intent.displayFormat = format // Assign directly
            intent.refreshInterval = 10   // Assign directly

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

    var body: some View {
        Text(entry.value)
            .font(.system(size: 14, weight: .bold))
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(.center)
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
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular])
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
