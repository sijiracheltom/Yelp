//
//  Utilities.swift
//  Yelp
//
//  Created by Siji Rachel Tom on 9/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

enum YelpSortMode: Int {
    case bestMatched = 0, distance, highestRated, totalCount
}

func sortModeText(sortMode : YelpSortMode) -> String {
    switch sortMode {
    case .bestMatched:
        return "Best Match"
    case .distance:
        return "Distance"
    case .highestRated:
        return "Highest Rated"
    default:
        return ""
    }
}

enum YelpDistanceMode : Int {
    case auto = 0
    case pointThreeMiles
    case oneMile
    case fiveMiles
    case twentyMiles
    case totalCount
}

func distanceInMeters(distanceMode : YelpDistanceMode) -> Int {
    switch distanceMode {
    case .auto:
        return 40000
    case .pointThreeMiles:
        return 482
    case .oneMile:
        return 1609
    case .fiveMiles:
        return 8046
    case .twentyMiles:
        return 32186
    case .totalCount:
        return 0
    }
}

func distanceModeText(distanceMode : YelpDistanceMode) -> String {
    switch distanceMode {
    case .auto:
        return "Auto"
    case .pointThreeMiles:
        return "0.3 miles"
    case .oneMile:
        return "1 mile"
    case .fiveMiles:
        return "5 miles"
    case .twentyMiles:
        return "20 miles"
    default:
        return ""
    }
}
