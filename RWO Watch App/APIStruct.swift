//
//  APIStrut.swift
//  RWO
//
//  Created by Jonathan Gan on 2/22/25.
//


import Foundation

// MARK: - RetardioResponse
/// Model to decode the response from the Retardio API.
public struct RetardioResponse: Decodable {
    // Prices
    let priceOfSol: Double
    let priceOfBtc: Double
    let priceOfEth: Double
    
    // Symbol and listings
    let symbol: String
    let listedCount: Int
    
    // Volume and transaction data
    let volume24hr: Double
    let txns24hr: Int
    let avgPrice24hr: Double
    let deltaFloor24hr: Double
    let fpPctChg24hr: Double
    
    let volume7d: Double
    let txns7d: Int
    let avgPrice7d: Double
    let deltaFloor7d: Double
    let fpPctChg7d: Double
    
    let volume30d: Double
    let txns30d: Int
    let avgPrice30d: Double
    let deltaFloor30d: Double
    let fpPctChg30d: Double
    
    let volumeAll: Double
    
    // FloorNFT and FloorNFTWithFee
    let floorNFT: FloorNFT
    let floorNFTWithFee: FloorNFTWithFee
    
    // Other details
    let totalSpins24hr: Int
    let floorPrice: Double
    let floorUsdValue: Double
    let uiFloorFormatted: String
    let quoteUsdValue: Double
    let uiQuoteFormatted: String
}

// MARK: - FloorNFT
/// Model for the floor NFT details.
public struct FloorNFT: Decodable {
    let mintAddress: String
    let price: Double
    let listingType: String
    let tokenStandard: Int
    let owner: String
    let sellerFeeBasisPoints: Int
}

// MARK: - FloorNFTWithFee
/// Model for the floor NFT details with fee and AMM (Automated Market Maker) information.
public struct FloorNFTWithFee: Decodable {
    let mintAddress: String
    let price: Double
    let listingType: String
    let tokenStandard: Int
    let owner: String
    let sellerFeeBasisPoints: Int
    let correctedPrice: Double
    let amm: Amm?
}

// MARK: - Amm
/// Model for the AMM details within the floorNFTWithFee.
public struct Amm: Decodable {
    let poolKey: String
    let source: String
    let spotPrice: Double
    let curveType: String
    let curveDelta: Double
    let lpFeeBp: Int
    let poolType: String
    let poolIdentifier: String
    let nextSpotPrice: Double
}
