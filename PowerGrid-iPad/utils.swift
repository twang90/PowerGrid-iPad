//
//  utils.swift
//  PowerGrid-iPad
//
//  Created by Tiancong Wang on 8/27/18.
//  Copyright © 2018 Justin&Nick. All rights reserved.
//

import Foundation

func random(_ n:Int) -> Int
{
    return Int(arc4random_uniform(UInt32(n)))
}

let titles = ["Phase 1: The First City",
              "Phase 2: Auction Power Plants",
              "Phase 3: Buying Resources",
              "Phase 4: Building",
              "Special Ability"]

let descriptions = [["Last Choice",
                     "Random Choice",
                     "Early Choice for All",
                     "Player's Choice",
                     "Bidding Choice",
                     "Deciding Choice"],
                    ["Using Cheapest Resources\n(Maximum Bid: Minimum Bid + 5 Elektro)",
                     "Buys the First Choice for Minimum Bid","Supplying Most Cities\n(Maximum Bid: Minimum Bid + 10 Elektro)",
                     "Highest Number\n(Maximum Bid: Minimum Bid + # of Own Cities)",
                     "Second Smallest Number\n(Maximum Bid: Minimum Bid)",
                     "All Power Plants\n(Maximum Bid: Minimum Bid + 1 Elektro)"],
                    ["Normal Production and Less Than 5 Elektro",
                     "All Resources","(Last)All Resources,\nOtherwise Normal Production",
                     "Normal Production",
                     "Normal Production and Least Available Resources",
                     "Odd Turn: Normal Production,\nEven Turn: All Resources"],
                    ["Last Player Chooses\n(Cannot Build Through Possible Cities)",
                     "All Cities\n(Never More Than First Player)",
                     "Only Supplied Cities",
                     "Step 1: All Cities, Less Than 7;\nOtherwise: All Cities Never to First Player",
                     "Step 1: 1 City, Step 2: 2 Cities, Step 3: 3 Cities",
                     "All Cities"],
                    ["Game Start: Gets 100 Elektro",
                     "Phase 1: Always Last in Player Order",
                     "Phase 2: Pays Half Bid For Power Plants",
                     "Phase 4: All Cities Cost 10 Elektro",
                     "Phase 4: Always Builds First City For 0 Elektro",
                     "Phase 5: Gets Income for +1 City"]]

class Player {
    init() {
        money = 50
        human = true
    }
    var money: Int
    var human: Bool
}

class PGBot : Player {
    override init() {
        // Random generate properities
        properties = [random(6), random(6), random(6), random(6), random(6)]
        super.init()
        human = false
        if properties[4] == 0 { // Special ability is about start money
            money = 100
        }
    }
    
    func getOutput() -> [String] {
        var ret : [String] = []
        for i in 0...descriptions.count-1 {
            ret.append(descriptions[i][properties[i]])
        }
        return ret
    }
    
    var properties : [Int]
}
