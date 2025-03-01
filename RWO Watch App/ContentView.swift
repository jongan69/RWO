//
//  ContentView.swift
//  RWO Watch App
//
//  Created by Jonathan Gan on 2/22/25.
//

import SwiftUI
import ClockKit

struct ContentView: View {
    @StateObject private var apiService = APIService()
    @State private var isLoading = false  // Track loading state
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.black]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView { // Allows scrolling if content is too long
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        Image("logo") // Replace with your actual image name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40) // Adjust size as needed
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(radius: 3)

                        Text("Retardio Stats")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8) // Adds space from the top
                    
                    if let data = apiService.data {
                        // Display Data
                        StatRow(title: "Floor Price", value: data.uiFloorFormatted)
                        
                        // Floor Price Change over Intervals
                        FloorPriceChangeRow(title: "Floor Price (24h)", change: data.fpPctChg24hr, solPrice: data.priceOfSol, floorPrice: data.floorPrice)
                        FloorPriceChangeRow(title: "Floor Price (7d)", change: data.fpPctChg7d, solPrice: data.priceOfSol, floorPrice: data.floorPrice)
                        FloorPriceChangeRow(title: "Floor Price (30d)", change: data.fpPctChg30d, solPrice: data.priceOfSol, floorPrice: data.floorPrice)

                        StatRow(title: "Coin Price", value: data.uiQuoteFormatted)
                        StatRow(title: "Solana Price", value: String(format: "$%.2f", data.priceOfSol))
                        StatRow(title: "Bitcoin Price", value: String(format: "$%.2f", data.priceOfBtc))
                        StatRow(title: "Ethereum Price", value: String(format: "$%.2f", data.priceOfEth))
                        StatRow(title: "Listed Count", value: "\(data.listedCount)")
                        StatRow(title: "24h Volume", value: "\(formatNumber(data.volume24hr)) SOL")
                        StatRow(title: "24h Avg Price", value: String(format: "$%.2f", (data.avgPrice24hr * data.priceOfSol)))
                        StatRow(title: "7d Volume", value: "\(formatNumber(data.volume7d)) SOL")
                        StatRow(title: "30d Volume", value: "\(formatNumber(data.volume30d)) SOL")
                        StatRow(title: "Total Volume", value: "\(formatNumber(data.volumeAll)) SOL")
                    } else if let errorMessage = apiService.errorMessage {
                        VStack(spacing: 8) {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 5)
                            
                            Button(action: {
                                Task {
                                    await refreshData()
                                }
                            }) {
                                Text("Retry")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                        }
                    } else {
                        ProgressView("Fetching Data...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .font(.system(size: 14))
                    }
                    
                    Button(action: {
                        Task {
                            await refreshData()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.clockwise")
                                Text("Refresh")
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity) // Ensures button takes full width if needed
                        .background(isLoading ? Color.red.opacity(0.8) : Color.black.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 8)) // Ensures full rounded corners
                        .animation(.easeInOut, value: isLoading) // Smooth transition
                    }
                    .buttonStyle(PlainButtonStyle()) // Ensures the entire button is affected
                    .disabled(isLoading)
                    .padding(.top, 10)

                }
                .padding(10)
            }
        }
        .onAppear {
            Task {
                await refreshData()
            }
        }
    }
    
    private func refreshData() async {
        DispatchQueue.main.async {
            isLoading = true
        }
        
        await apiService.fetchData()
        updateComplications()
        
        DispatchQueue.main.async {
            isLoading = false
        }
    }

    // Function to Update Complications
    private func updateComplications() {
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
    }
    
    // Format number for better readability (for large numbers)
    private func formatNumber(_ value: Double) -> String {
        return String(format: "%.2f", value)
    }
}

// Reusable Stat Row with Title and Value in Separate Rows
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity) // Centers the title
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1) // Prevents wrapping
                .minimumScaleFactor(0.6) // Shrinks text to fit if necessary
                .frame(maxWidth: .infinity) // Centers the title
        }
        .padding(.horizontal, 10)
    }
}

// Floor Price Change Row (Color-Coded Based on Positive/Negative Change)
struct FloorPriceChangeRow: View {
    let title: String
    let change: Double // Change in percentage
    let solPrice: Double // Price of Solana in USD
    let floorPrice: Double // Floor Price in Sol
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity) // Centers the title
            
            let changeInUSD = (change / 100) * floorPrice * solPrice // Calculate the change in USD

            HStack {
                // Display the change in USD
                Text(String(format: "$%.2f", changeInUSD))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(change >= 0 ? .green : .red) // Green for positive, Red for negative

                // Display the percentage change in parentheses
                Text(String(format: "(%.2f%%)", change))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .lineLimit(1) // Prevents wrapping
            .minimumScaleFactor(0.6) // Shrinks text to fit if necessary
            .frame(maxWidth: .infinity) // Centers the title
        }
        .padding(.horizontal, 10)
    }
}


#Preview {
    ContentView()
}
