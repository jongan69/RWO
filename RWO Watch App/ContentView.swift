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
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
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
                        StatRow(title: "Coin Price", value: data.uiQuoteFormatted)
                    } else if let errorMessage = apiService.errorMessage {
                        VStack(spacing: 8) {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 5)
                            
                            Button(action: {
                                Task {
                                    await apiService.fetchData()
                                    updateComplications()
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
                }
                .padding(10)
            }
        }
        .onAppear {
            Task {
                await apiService.fetchData()
                updateComplications()
            }
        }
    }
    
    // Function to Update Complications
    private func updateComplications() {
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
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
                .foregroundColor(.yellow)
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
