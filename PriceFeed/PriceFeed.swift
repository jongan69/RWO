import WidgetKit
import SwiftUI
import AppIntents

// Fetch data asynchronously
func fetchComplicationData(displayFormat: PriceDisplayOption) async -> String {
    guard let url = URL(string: "https://www.retardio.exposed/api/combined") else {
        return "--"
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
        return "--"
    }
}

// Widget provider
struct RWOComplicationProvider: AppIntentTimelineProvider {
    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        [
            AppIntentRecommendation(
                intent: ConfigurationAppIntent(
                    displayFormat: IntentParameter(title: "Display Format", default: .sol),
                    refreshInterval: IntentParameter(title: "Refresh Interval", default: 10)
                ),
                description: "Display price in SOL"
            ),
            AppIntentRecommendation(
                intent: ConfigurationAppIntent(
                    displayFormat: IntentParameter(title: "Display Format", default: .usd),
                    refreshInterval: IntentParameter(title: "Refresh Interval", default: 10)
                ),
                description: "Display price in USD"
            ),
            AppIntentRecommendation(
                intent: ConfigurationAppIntent(
                    displayFormat: IntentParameter(title: "Display Format", default: .both),
                    refreshInterval: IntentParameter(title: "Refresh Interval", default: 10)
                ),
                description: "Display SOL & USD (Default)"
            )
        ]
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
        
        // Apply user-defined refresh interval
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: configuration.refreshInterval, to: Date())!
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
