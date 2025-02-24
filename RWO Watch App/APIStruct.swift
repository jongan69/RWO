//
//  APIStrut.swift
//  RWO
//
//  Created by Jonathan Gan on 2/22/25.
//


import Foundation

// MARK: - RetardioResponse
public struct RetardioResponse: Decodable {
    let floorPrice: Double
    let floorUsdValue: Double
    let uiFloorFormatted: String
    let quoteUsdValue: Double
    let uiQuoteFormatted: String
}
