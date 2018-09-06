//
//  utils.swift
//  PowerGrid-iPad
//
//  Created by Tiancong Wang on 8/27/18.
//  Copyright © 2018 Justin&Nick. All rights reserved.
//

import Foundation
import UIKit

func random(_ n:Int) -> Int
{
    return Int(arc4random_uniform(UInt32(n)))
}

extension UIView {
    func intersectView(view: UIView) -> Bool {
        return self.frame.intersects(view.superview!.convert(view.frame, to: self.superview!))
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
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

// Model for players and companies in Stock Companies
let allCompanyColors = [#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.5075493847, blue: 0.05575504658, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)]

let initialPricesForCompanies = [#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1): 20,
                                 #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1): 20,
                                 #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1): 30,
                                 #colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1): 30,
                                 #colorLiteral(red: 0, green: 0.5075493847, blue: 0.05575504658, alpha: 1): 40,
                                 #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1): 40]

let namesForTheColors = [#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1): "Blue",
                         #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1): "Black",
                         #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1): "Red",
                         #colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1): "Yellow",
                         #colorLiteral(red: 0, green: 0.5075493847, blue: 0.05575504658, alpha: 1): "Green",
                         #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1): "Purple"]

let initialMoneyForStockCompanies = [0, 0, 300, 200, 150, 120, 120]

enum BoughtOrSold {
    case None
    case Bought
    case Sold
}

class PlayerInStockCompanies : Player {
    init(companies: Int, money: Int) {
        stocks = Dictionary()
        for i in 0...companies-1 {
            stocks[allCompanyColors[i]] = 0
        }
        name = ""
        super.init()
        self.money = money
    }
    
    var stocks : [UIColor: Int]
    var name : String
}

class Company : Player {
    init(c: UIColor) {
        color = c
        name = namesForTheColors[c]!
        shares = 10
        initPrice = initialPricesForCompanies[color]!
        currentPrice = initPrice
        owner = nil
        super.init()
        money = 0
    }
    
    var shares : Int
    var initPrice : Int
    var currentPrice : Int
    var owner : PlayerInStockCompanies?
    var color : UIColor
    var name : String
}

class StockExchange {
    static func readMoneyAmountFromMessage(message: String) -> Int {
        assert ( message.contains("{") && message.contains("}") )
        let start = message.suffix(from: message.index(after: message.index(of: "{")!))
        let end = start.prefix(upTo: start.index(of: "}")!)
        print (message)
        print (end)
        return Int(end)!
    }
    
    init(p: Int) {
        players = []
        stocksInMarket = Dictionary()
        companies = Dictionary()
        open = false
        log = []
        
        if p < 6 {
            for i in 0...4 {
                stocksInMarket[allCompanyColors[i]] = 0
                companies[allCompanyColors[i]] = Company(c: allCompanyColors[i])
            }
            for _ in 0...p-1 {
                players.append(PlayerInStockCompanies(companies: 5, money: initialMoneyForStockCompanies[p]))
            }
        }
        else {
            for i in 0...5 {
                stocksInMarket[allCompanyColors[i]] = 0
                companies[allCompanyColors[i]] = Company(c: allCompanyColors[i])
            }
            for _ in 0...p-1 {
                players.append(PlayerInStockCompanies(companies: 6,  money: initialMoneyForStockCompanies[p]))
            }
        }
    }
    
    func updateOwner(c: Company) {
        var maxShare : Int = 0
        if c.owner == nil {
            // If no owner, whoever owns two shares becomes the owner
            for p in players {
                if p.stocks[c.color]! > maxShare {
                    maxShare = p.stocks[c.color]!
                    c.owner = p
                }
            }
            assert (maxShare == 0 || maxShare == 2)
        }
        else {
            maxShare = c.owner!.stocks[c.color]!
            for p in players {
                if p.stocks[c.color]! > maxShare {
                    maxShare = p.stocks[c.color]!
                    c.owner = p
                }
            }
        }
    }
    
    func openMarket() {
        open = true
        log = []
        for _ in players {
            var playerLog = Dictionary<UIColor, BoughtOrSold>()
            for c in companies.keys {
                playerLog[c] = BoughtOrSold.None
            }
            log.append(playerLog)
        }
        print("Market is open\n")
        print(log)
    }
    
    func checkCanBuy(player: PlayerInStockCompanies, color: UIColor) -> Bool {
        let stock = player.stocks[color]!
        let c = companies[color]!
        let market = stocksInMarket[color]!
        
        var toBuy : Int = 1
        if (c.shares == 10) {
            // The first buyer
            toBuy = 2
        }
        
        if stock >= 5 {
            return false
        }
        else if player.money < c.currentPrice * toBuy {
            return false
        }
        else if (c.shares + stocksInMarket[color]! == 0) {
            return false
        }
        else if (log[players.index{$0 === player}!][color] == BoughtOrSold.Sold) {
            return false
        }
        
        return true
    }
    
    func maxToSell(player: PlayerInStockCompanies, color: UIColor) -> Int {
        let stock = player.stocks[color]!
        let c = companies[color]!
        let market = stocksInMarket[color]!
        
        if log[players.index{$0 === player}!][color] == BoughtOrSold.Bought {
            return 0
        }
        
        if c.owner?.name == player.name {
            // The player is the owner, need to consider selling will result in others can't be the owner
            // Check if others can be the owner
            var foundCandidate : Bool = false
            for p in players {
                if p.name != player.name {
                    if p.stocks[color]! >= 2 {
                        foundCandidate = true
                    }
                }
            }
            if !foundCandidate {
                // Player can leave at least 2 shares, or the market can maximum own 5 shares
                return max(0, min(stock-2, 5-market))
            }
            else {
                return min(stock, 5-market)
            }
        }
        else {
            // If the player is not the owner, the player can sell as long as the market can hold
            return min(stock, 5-market)
        }
    }
    
    func trade(player: PlayerInStockCompanies, seller: String, color: UIColor, count: Int = 1)  -> (Bool, String)  {
        assert(open)
        
        let c = companies[color]!

        if seller == "Company" ||
            seller == "Bank" {
            // Buy from company
            var toBuy : Int = count
            assert (toBuy == 1)
            
            if (c.shares == 10) {
                // The first buyer
                toBuy = 2
            }
            
            /*
            if (player.stocks[color]! >= 5) {
                // Player already owns over 50% stock
                return (false, "Player " + player.name + " already has 50% of the stock of <" + c.name+">")
            }
            else if (player.money < c.currentPrice * toBuy) {
                // Player can't pay the stock price
                return (false, "[Player " + player.name + "] doesn\'t have enought money for the stock of <"+c.name+">")
            }
            else if (c.shares + stocksInMarket[color]! == 0) {
                // There's no enough stocks on the market
                return (false, "All stocks of <" + c.name + "> are sold out")
            }
            else if (log[players.index{$0 === player}!][color] == BoughtOrSold.Sold) {
                // The player has sold the stock in the current round
                return (false, "Player [" + player.name + "] has already sold share(s) of the stock of <" + c.name + "> in the current Trade Round")
            }
                 */
            assert (player.stocks[color]! < 5 && player.money >= c.currentPrice * toBuy && c.shares + stocksInMarket[color]! > 0 && log[players.index{$0 === player}!][color] != BoughtOrSold.Sold)
            
            // Player buys share
            player.stocks[color]! += toBuy
            player.money -= c.currentPrice * toBuy
            log[players.index{$0 === player}!][color] = BoughtOrSold.Bought
                
            if (seller == "Company") {
                assert (c.shares > 0)
                // Company sells the share
                c.shares -= toBuy
                c.money += c.initPrice * toBuy
                updateOwner(c: c)
                return (true, "Player [" + player.name + "] successfully buys " + String(toBuy) + " share(s) of stock of <" + c.name + "> from the company for {" + String(c.currentPrice * toBuy) + "}")
            }
            else {
                // Bank sells the share
                assert(c.shares == 0)
                assert(toBuy == 1)
                stocksInMarket[color]! -= 1
                updateOwner(c: c)
                return (true, "Player [" + player.name + "] successfully buys one share of stock of <" + c.name + "> from the market for {" + String(c.currentPrice * toBuy) + "}")
            }
        }
        else {
            assert (seller == "Player")
            // Play sells the share
            assert (player.stocks[color]! >= count && stocksInMarket[color]! + count <= 5 && log[players.index{$0 === player}!][color] != BoughtOrSold.Bought)
            /*
            if (stock < count) {
                // Can't sell more shares than the player owns
                return (false, "Player [" + player.name + "] can\'t sell more shares than the player owns: <" + c.name + ">, player has" + String(stock) + " but wants to sell " + String(count))
            }
            else if (stocksInMarket[color]! + count > 5) {
                // Can't sell more if market has already have 50%
                return (false, "Player [" + player.name + "] can\'t sell to market because it results in market has over 50% of <" + c.name + ">: market has " + String(stocksInMarket[color]!) + " and player wants to sell " + String(count))
            }
             */
            
            player.money += c.currentPrice * count
            player.stocks[color]! -= count
            stocksInMarket[color]! += count
            log[players.index{$0 === player}!][color] = BoughtOrSold.Sold
            let money = c.currentPrice * count
            // Reduce price
            if (c.currentPrice > 10) {
                c.currentPrice -= 10
            }
            else {
                c.currentPrice = 10
            }
            updateOwner(c: c)
            return (true, "Player [" + player.name + "] sells " + String(count) + " shares of <" + c.name + "> to the market for {" + String(money) + "}")
        }
    }
    
    func closeMarket(color: UIColor) -> Bool {
        let c = companies[color]!
        if c.shares == 0 && stocksInMarket[color] == 0 {
            print (c.name + " increase prices")
            if (c.currentPrice < 140) {
                c.currentPrice += 10
            }
            else{
                c.currentPrice = 140
            }
            return true
        }
        else {
            return false
        }
    }
    
    func earnProfit(color: UIColor, cities: Int, distribute: Bool) -> ([Int], Int) {
        assert (cities >= 1)
        let income = 20 + 10 * (cities - 1)
        let c = companies[color]!
        
        if !distribute {
            // Put money into the company
            c.money += income
            return ([], income)
        }
        else {
            let perShare = income / 10
            var ret : [Int] = []
            // Distribute incomes
            for p in players {
                p.money += p.stocks[color]! * perShare
                ret.append(p.stocks[color]! * perShare)
            }
            c.money += c.shares * perShare
            // Increase price
            if (c.currentPrice < 140) {
                c.currentPrice += 10
            }
            else{
                c.currentPrice = 140
            }
            return (ret, c.shares * perShare)
        }
    }
    
    var stocksInMarket : [UIColor: Int]
    var companies : [UIColor: Company]
    var players: [PlayerInStockCompanies]
    var open : Bool
    var log : [[UIColor: BoughtOrSold]]
}
