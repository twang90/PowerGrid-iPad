//
//  StockCompany.swift
//  PowerGrid-iPad
//
//  Created by Tiancong Wang on 8/28/18.
//  Copyright © 2018 Justin&Nick. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerStockCompanyMain: UIViewController {
    var exchange : StockExchange? = nil
    var round : Int = 0
    var companyColors : [UIColor]? = nil
    var players : [PlayerInStockCompanies?] = []
    var validPlayersToBuy : [UIView] = []
    
    // Game status region
    @IBOutlet var stockPriceButtons: [UIButton]!
    @IBOutlet weak var gameProgressView: UIProgressView!
    @IBOutlet weak var gameWinnerLabel: UILabel!
    @IBOutlet weak var warningMessage: UILabel!
    @IBOutlet weak var warningMessageButton: UIButton!
    
    // Player outlets
    @IBOutlet var playerViews: [UIView]!
    @IBOutlet var playerNameTextFields: [UITextField]!
    @IBOutlet var playerSwitch: [UISwitch]!
    @IBOutlet var playerElektroButtons: [UIButton]!
    @IBOutlet var playerStockViews: [UIView]!
    @IBOutlet var playerStockButtons: [UIButton]!
    
    // Company outlets
    @IBOutlet var companyViews: [UIView]!
    @IBOutlet var companyPresidentNames: [UILabel]!
    @IBOutlet var companyShareSlotLabels: [UILabel]!
    @IBOutlet var companyElektroButtons: [UIButton]!
    @IBOutlet var companyShareButtons: [UIButton]!
    @IBOutlet var companySharePriceLabels: [UILabel]!
    
    // Bank outlets
    @IBOutlet var bankShareButtons: [UIButton]!
    @IBOutlet var bankShareSlots: [UILabel]!
    @IBOutlet weak var bankView: UIView!
    
    // Forward game progress
    @IBAction func clickToProgressGame(_ sender: UIButton, forEvent event: UIEvent) {
        let text = sender.title(for: .normal)!
        
        if text == "Preparation" {
            sender.setTitle("Trade " + String(round+1), for: .normal)
            gameProgressView.isHidden = false
            gameProgressView.progress = 0.0
            gameProgressView.transform = gameProgressView.transform.scaledBy(x: 1, y: 8)
            prepareGame()
            initializeStockPrices()
            exchange!.openMarket()
            for b in companyElektroButtons {
                b.isEnabled = false
                b.alpha = 0.2
            }
        }
        else if text.contains("Trade") {
            sender.setTitle("Business " + String(round+1), for: .normal)
            updateStockPrices()
            for b in companyShareButtons {
                b.isEnabled = false
                b.alpha = 0.2
            }
            for b in companyElektroButtons {
                if exchange!.companies[b.backgroundColor!]?.owner != nil {
                    b.isEnabled = true
                    b.alpha = 1.0
                }
            }
        }
        else if text.contains("Business") {
            round += 1
            gameProgressView.progress += 1.0 / 5
            if text == "Business 1" {
                sender.setTitle("Business " + String(round+1), for: .normal)
            }
            else if round < 5 {
                sender.setTitle("Trade " + String(round+1), for: .normal)
                exchange!.openMarket()
                for b in companyShareButtons {
                    if exchange!.companies[b.backgroundColor!] != nil && exchange!.companies[b.backgroundColor!]!.shares > 0 {
                        b.isEnabled = true
                        b.alpha = 1
                    }
                }
                for b in companyElektroButtons {
                    b.isEnabled = false
                    b.alpha = 0.2
                }
            }
            else {
                sender.setTitle("Done", for: .normal)
                sender.isEnabled = false
            }
        }
        else {
            print ("Wrong status")
            assert (false)
        }
    }
    
    // Display message
    func displayWarningMessage(message: String) {
        warningMessage.isHidden = false
        warningMessageButton.isHidden = false
        warningMessage.numberOfLines = 0
        warningMessage.text = message
    }
    
    
    
    /////////////////////////////////////////////////
    ///////      Game setup functions          //////
    /////////////////////////////////////////////////
    
    func displayPlayer(index: Int) {
        let player = players[index]!
        if (playerNameTextFields[index].text == "") {
            player.name = "Player " + String(index+1)
        }
        else{
            player.name = playerNameTextFields[index].text!
        }
        playerNameTextFields[index].isEnabled = false
        playerSwitch[index].isHidden = true
        playerElektroButtons[index].isHidden = false
        playerStockViews[index].isHidden = false
    }
    
    func updatePlayer(index: Int, p: Player) {
        //To do: update player stock
        //let player = players[index]!
    }
    
    func updateCompany(index: Int, c: Company) {
        companyShareSlotLabels[index].text = String(c.shares)
        companyShareButtons[index].setTitle(String(c.shares), for: .normal)
        if c.shares == 0 {
            companyShareButtons[index].isEnabled = false
            companyShareButtons[index].alpha = 0.2
            for b in bankShareButtons {
                if b.backgroundColor! == companyShareButtons[index].backgroundColor! {
                    b.isEnabled = true
                    b.alpha = 1.0
                    break
                }
            }
        }
        
        companySharePriceLabels[index].text = String(c.currentPrice)
        
        if (c.owner != nil) {
            companyPresidentNames[index].text = c.owner?.name
        }
        companyElektroButtons[index].setTitle(String(c.money), for: .normal)
    }
    
    func updateGameStatus() {
        for b in stockPriceButtons {
            if !b.isHidden {
                if exchange!.companies[b.backgroundColor!]!.owner != nil {
                    b.alpha = 1.0
                }
            }
        }
    }
    
    func displayCompany(index: Int) {
        let company = exchange!.companies[allCompanyColors[index]]!
        companyViews[index].backgroundColor = companyColors?[index].withAlphaComponent(0.5)
        if company.owner == nil {
            companyPresidentNames[index].text = "No Owner"
        }
        else {
            companyPresidentNames[index].text = company.owner?.name
        }
        companyShareSlotLabels[index].text = String(company.shares)
        companyShareSlotLabels[index].textColor = .white
        companyShareSlotLabels[index].backgroundColor = companyColors?[index]
        companyShareButtons[index].isHidden = false
        companyShareButtons[index].setTitle(String(company.shares), for: .normal)
        companyShareButtons[index].setTitleColor(.white, for: .normal)
        companyShareButtons[index].backgroundColor = companyColors?[index]
        companyShareButtons[index].layer.cornerRadius = 0.2 * companyShareButtons[index].bounds.size.width
        companyShareButtons[index].center = companyViews[index].convert(companyShareSlotLabels[index].center, to: companyShareButtons[index].superview)
        
        companyElektroButtons[index].setTitle(String(company.money), for: .normal)
        companyElektroButtons[index].setTitleColor(.white, for: .normal)
        companyElektroButtons[index].backgroundColor = companyColors![index]
        companySharePriceLabels[index].isHidden = false
        companySharePriceLabels[index].backgroundColor = companyColors![index]
        companySharePriceLabels[index].text = String(company.currentPrice)
        companySharePriceLabels[index].layer.cornerRadius = 0.2 * companySharePriceLabels[index].bounds.size.width
    }
    
    func displayBank() {
        let colors = Array(exchange!.companies.keys)
        for i in 0...bankShareButtons.count-1 {
            if (i < colors.count) {
                bankShareButtons[i].backgroundColor = colors[i]
                bankShareButtons[i].layer.cornerRadius = 0.2 * bankShareButtons[i].bounds.size.width
                bankShareButtons[i].isEnabled = false
                bankShareButtons[i].alpha = 0.2
                bankShareButtons[i].center = bankView.convert(bankShareSlots[i].center, to: bankShareButtons[i].superview)
            }
        }
    }
    
    func prepareGame() {
        // Count players
        var numActivePlayers : Int = 0
        for s in playerSwitch {
            if s.isOn {
                numActivePlayers += 1
            }
        }
        
        // Prepare stock exchange market
        exchange = StockExchange(p: numActivePlayers)
        
        numActivePlayers = 0
        for i in 0...playerSwitch.count-1 {
            if playerSwitch[i].isOn {
               players.append(exchange!.players[numActivePlayers])
                numActivePlayers += 1
                displayPlayer(index: i)
            }
            else {
                players.append(nil)
                playerViews[i].isHidden = true
            }
        }
        
        // Shuffle company colors
        companyColors = Array(allCompanyColors.prefix((exchange?.companies.count)!))
        companyColors!.shuffle()

        // Prepare companies
        for i in 0...exchange!.companies.count-1 {
            displayCompany(index: i)
            companyViews[i].isHidden = false
        }
        
        // Prepare bank
        displayBank()
    }
    
    func initializeStockPrices() {
        var stocks : [UIColor: Int] = Dictionary()
        for c in companyColors! {
            stocks[c] = exchange!.companies[c]!.currentPrice
        }
        let sortedStocks = stocks.sorted(by: {
            if ($0.value == $1.value) {
                return random(2) == 1
            }
            else {
                return $0.value < $1.value
            }
        })
        print(sortedStocks)
        for i in 0...stockPriceButtons.count-1 {
            if i < sortedStocks.count {
                stockPriceButtons[i].isHidden = false
                stockPriceButtons[i].backgroundColor = sortedStocks[i].key
                stockPriceButtons[i].setTitle(String(sortedStocks[i].value), for: .normal)
                stockPriceButtons[i].layer.cornerRadius = 0.2 * stockPriceButtons[i].bounds.size.width
                stockPriceButtons[i].alpha = 0.2
            }
        }
    }
    
    func swapViewPositions (v1: UIView, v2: UIView) {
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            swap(&v1.center, &v2.center)
        }, completion: {(true) -> Void in
            print ("Swap " + self.exchange!.companies[v1.backgroundColor!]!.name + " and " + self.exchange!.companies[v2.backgroundColor!]!.name)
            return
        })
    }
    
    func updateStockPrices() {
        var oldStockOrder : [UIColor] = []
        
        let sortedButtons = stockPriceButtons.sorted(by: {
            if ($0.center.x == $1.center.x) {
                return $0.center.y < $1.center.y
            }
            else {
                return $0.center.x < $1.center.x
            }
        })
        
        for b in sortedButtons {
            if !b.isHidden {
                oldStockOrder.append(b.backgroundColor!)
            }
        }
        
        for c in oldStockOrder.reversed() {
            let result = exchange!.closeMarket(color: c)
            if result {
                updateStockPrices(c: c, decrease: false)
            }
        }
    }
    
    func updateStockPrices(c: UIColor, decrease: Bool) {
        var oldStockOrder : [UIColor] = []
        var movableButtons : [UIButton] = []
        
        let sortedButtons = stockPriceButtons.sorted(by: {
            if ($0.center.y == $1.center.y) {
                return $0.center.x < $1.center.x
            }
            else {
                return $0.center.y < $1.center.y
            }
        })
        print (sortedButtons)
        
        for b in sortedButtons {
            if !b.isHidden {
                oldStockOrder.append(b.backgroundColor!)
                movableButtons.append(b)
            }
        }
        
        let index = oldStockOrder.index(of: c)!
        let button = movableButtons[index]
        let price = exchange!.companies[c]!.currentPrice
        button.setTitle(String(price), for: .normal)
        
        if decrease {
            if (index == 0) {
                return
            }
            let smallerButtons = movableButtons.prefix(upTo: index)
            for b in smallerButtons.reversed() {
                if exchange!.companies[b.backgroundColor!]!.currentPrice > price {
                    swapViewPositions(v1: button, v2: b)
                }
                else {
                    break
                }
            }
        }
        else {
            if (index == oldStockOrder.count-1) {
                return
            }
            let largerButtons = movableButtons.suffix(from: Int(index) + 1)
            for b in largerButtons {
                if exchange!.companies[b.backgroundColor!]!.currentPrice <= price {
                    swapViewPositions(v1: button, v2: b)
                }
                else {
                    break
                }
            }
        }
    }
    
    
    @IBAction func playerShowMoneyStart(_ sender: UIButton, forEvent event: UIEvent) {
        let index = playerElektroButtons.index(of: sender)!
        let player = players[index]!
        sender.setTitle(String(player.money), for: .normal)
    }
    
    @IBAction func playerShowMoneyEnd(_ sender: UIButton, forEvent event: UIEvent) {
        sender.setTitle("Elektro", for: .normal)
    }
    
    
    /////////////////////////////////////////////////
    ///////      Trade round functions         //////
    /////////////////////////////////////////////////
    
    func moneyExchangeAnimation(from: UIView, to: UIView, value: Int) {
         let source = from.superview!.convert(from.center, to: self.view)
        let dest = to.superview!.convert(to.center, to: self.view)
        
        let moneyCoinButton = UIButton()
        self.view.addSubview(moneyCoinButton)
        let size = CGSize(width: 80, height: 80)
        let origin = CGPoint(x: source.x - size.width/2, y: source.y - size.height / 2)
        moneyCoinButton.frame = CGRect(origin: origin, size: size)
        moneyCoinButton.setBackgroundImage(UIImage(named: "coin")!, for: .normal)
        
        moneyCoinButton.setTitle(String(value), for: .normal)
        moneyCoinButton.titleLabel!.font = UIFont(name: moneyCoinButton.titleLabel!.font.fontName, size: 30)
        moneyCoinButton.setTitleColor(.white, for: .normal)
        
        // Show animation
        UIView.animate(withDuration: 2.0, animations: {() -> Void in
            moneyCoinButton.center = dest
            //moneyCoinButton.alpha = 0
        }, completion: {(true) -> Void in
            moneyCoinButton.isHidden = true
            self.view.willRemoveSubview(moneyCoinButton)
        })
    }
    
    @IBAction func dragButtons(_ sender: UIButton, forEvent event: UIEvent) {
        if let center = event.allTouches?.first?.location(in: self.view) {
            // Move the button
            sender.center = center
            
            // Show all the players that can buy the share
            for i in 0...playerStockViews.count-1 {
                if !playerStockViews[i].isHidden {
                    let result =  exchange!.checkCanBuy(player: players[i]!, color: sender.backgroundColor!)
                    if result {
                       playerStockViews[i].layer.borderWidth = 5
                        
                       playerStockViews[i].layer.borderColor = UIColor.black.cgColor
                        validPlayersToBuy.append(playerStockViews[i])
                    }
                    else {
                        playerStockViews[i].alpha = 0.2
                    }
                }
            }
        }
    }

    @IBAction func dragToBuyShares(_ sender: UIButton, forEvent event: UIEvent) {
        for v in validPlayersToBuy {
            if v.intersectView(view: sender) {
                let i = playerStockViews.index(of: v)!
                // Reset button
                if let index = companyShareButtons.index(of: sender) {
                    sender.center = companyViews[index].convert(companyShareSlotLabels[index].center, to: sender.superview)
                    for v in playerStockViews {
                        v.layer.borderWidth = 0
                        v.alpha = 1
                    }
                    
                    // Do trade
                    let (result, message) = exchange!.trade(player: players[i]!, seller: "Company", color: sender.backgroundColor!)
                    
                    if result {
                        moneyExchangeAnimation(from: playerElektroButtons[i], to: companyElektroButtons[index], value: StockExchange.readMoneyAmountFromMessage(message: message))
                        
                        updateGameStatus()
                        updateCompany(index: index, c: exchange!.companies[sender.backgroundColor!]!)
                        updatePlayer(index: i, p: players[i]!)
                    }
                    else {
                        displayWarningMessage(message: message)
                    }
                }
                else if let index = bankShareButtons.index(of: sender) {
                    sender.center = bankView.convert(bankShareSlots[index].center, to: sender.superview)
                    for v in playerStockViews {
                        v.layer.borderWidth = 0
                        v.alpha = 1
                    }

                    
                    // Do trade
                    let (result, message) = exchange!.trade(player: players[i]!, seller: "Bank", color: sender.backgroundColor!)
                    
                    if result {
                        moneyExchangeAnimation(from: playerElektroButtons[i], to: bankView, value: StockExchange.readMoneyAmountFromMessage(message: message))
                        updateGameStatus()
                        updatePlayer(index: i, p: players[i]!)
                        let remain = exchange!.stocksInMarket[sender.backgroundColor!]!
                        bankShareButtons[index].setTitle(String(remain), for: .normal)
                        
                        if remain == 0 {
                            bankShareButtons[index].isHidden = true
                        }
                    }
                    else {
                        displayWarningMessage(message: message)
                    }
                }
                else {
                    assert (false)
                }
                validPlayersToBuy = []
                return
            }
        }
        // Reset button if no interactions
        if let index = companyShareButtons.index(of: sender) {
            sender.center = companyViews[index].convert(companyShareSlotLabels[index].center, to: sender.superview)
            for v in playerStockViews {
                v.layer.borderWidth = 0
                v.alpha = 1
            }
            validPlayersToBuy = []
        }
        else if let index = bankShareButtons.index(of: sender) {
            sender.center = bankView.convert(bankShareSlots[index].center, to: sender.superview)
            for v in playerStockViews {
                v.layer.borderWidth = 0
                v.alpha = 1
            }
            validPlayersToBuy = []
        }
    }
    
    
    @IBAction func clickToCloseWarningMessage(_ sender: UIButton, forEvent event: UIEvent) {
        warningMessageButton.isHidden = true
        warningMessage.isHidden = true
    }
    
    func sharesSoldByPlayer(index: Int, color: UIColor, money: Int, priceChange: Bool) {
        // Update Bank
        var button : UIButton? = nil
        for b in bankShareButtons {
            if b.backgroundColor == color {
                button = b
                break
            }
        }
        
        // Update bank
        button!.isHidden = false
        button!.setTitle(String(exchange!.stocksInMarket[color]!), for: .normal)
        
        // Animation
        moneyExchangeAnimation(from: bankView, to: playerElektroButtons[index], value: money)
        
        // Update price change
        if priceChange {
            // Update company view
            companySharePriceLabels[companyColors!.index(of: color)!].text = String(exchange!.companies[color]!.currentPrice)
            
            // Update game status board
            updateStockPrices(c: color, decrease: true)
        }
    }
    
    /////////////////////////////////////////////////
    ///////      Business round functions      //////
    /////////////////////////////////////////////////
    func companyEarnProfit(playerAmounts: [Int], color: UIColor, companyAmount: Int) {
        var index : Int = -1
        for c in companyShareButtons {
            if c.backgroundColor! == color {
                index = Int(companyShareButtons.index(of: c)!)
                break
            }
        }
        
        assert (index != -1)
        if playerAmounts == [] {
            // The company keeps all the money
            moneyExchangeAnimation(from: bankView, to: companyElektroButtons[index], value: companyAmount)
            companyElektroButtons[index].setTitle(String(exchange!.companies[color]!.money), for: .normal)
        }
        else {
            // The company distribute the profit
            for i in 0...playerAmounts.count-1 {
                if playerAmounts[i] > 0 {
                    moneyExchangeAnimation(from: bankView, to: playerElektroButtons[i], value: playerAmounts[i])
                }
            }
            if companyAmount > 0 {
                moneyExchangeAnimation(from: bankView, to: companyElektroButtons[index], value: companyAmount)
                companyElektroButtons[index].setTitle(String(exchange!.companies[color]!.money), for: .normal)
            }
        }
    }
    
    
    // Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let senderButton = sender as? UIButton {
            if let dest = segue.destination as? ViewControllerStockCompanyPlayer {
                dest.setPlayerBeforeSegue(p: players[playerStockButtons.index(of: senderButton)!]!,
                                          i: playerStockButtons.index(of: senderButton)!,
                                          e: exchange!,
                                          vc: self)
                return
            }
            else if let dest = segue.destination as? ViewControllerStockCompanyCompany {
                segue.destination.preferredContentSize = CGSize(width: 400, height: 400)
                dest.setCompanyBeforeSegue(c: exchange!.companies[senderButton.backgroundColor!]!, e: exchange!, vc: self)
                return
            }
        }
        assert (false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class ViewControllerStockCompanyPlayer: UIViewController {
    var index : Int? = nil // Index of the player view in the main VC
    var player : PlayerInStockCompanies? = nil
    var exchange : StockExchange? = nil
    var mainViewController : ViewControllerStockCompanyMain? = nil
    var currentShareButton : UIButton? = nil
    
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet var playerShareDistributions: [UIButton]!
    @IBOutlet var playerShareSlots: [UILabel]!
    
    @IBOutlet weak var sellRegionView: UIView!
    @IBOutlet weak var sellRegionTitle: UILabel!
    @IBOutlet weak var sellSharesStepper: UIStepper!
    @IBOutlet weak var sellSharesDisplay: UILabel!
    @IBOutlet weak var sellSharesDoneButton: UIButton!
    
    @IBOutlet weak var warningMessageLabel: UILabel!
    @IBOutlet weak var warningMessageButton: UIButton!
    
    @IBAction func showMoneyStart(_ sender: UIButton, forEvent event: UIEvent) {
        sender.setTitle(String(player!.money), for: .normal)
    }
    
    
    @IBAction func showMoneyEnd(_ sender: UIButton, forEvent event: UIEvent) {
        sender.setTitle("Elektro", for: .normal)
    }
    
    func setPlayerBeforeSegue(p: PlayerInStockCompanies, i: Int, e: StockExchange, vc: ViewControllerStockCompanyMain) {
        player = p
        index = i
        exchange = e
        mainViewController = vc
    }
    
    @IBAction func dragButton(_ sender: UIButton, forEvent event: UIEvent) {
        if let center = event.allTouches?.first?.location(in: self.view) {
            sender.center = center
        }
    }
    
    
    @IBAction func dragToSellShare(_ sender: UIButton, forEvent event: UIEvent) {
        if sellRegionView.intersectView(view: sender) {
            sender.center = playerShareSlots[playerShareDistributions.index(of: sender)!].center
            
            sellRegionTitle.isHidden = true
            sellRegionView.isHidden = false
            let maxSold = exchange!.maxToSell(player: player!, color: sender.backgroundColor!)
            assert (maxSold > 0)
            sellSharesStepper.maximumValue = Double(maxSold)
            sellSharesStepper.minimumValue = 0
            sellSharesStepper.stepValue = 1
            sellSharesDisplay.text = String(Int(sellSharesStepper.value))
            currentShareButton = sender
        }
    }
    
    @IBAction func sellStepperValueChanged(_ sender: UIStepper, forEvent event: UIEvent) {
        sellSharesDisplay.text = String(Int(sellSharesStepper.value))
    }
    
    
    @IBAction func clickToDismissWarningMessage(_ sender: UIButton, forEvent event: UIEvent) {
        warningMessageLabel.isHidden = true
        warningMessageButton.isHidden = true
    }
    
    @IBAction func clickToConfirmSellShares(_ sender: UIButton, forEvent event: UIEvent) {
        assert (currentShareButton != nil)
        let shares = Int(sellSharesDisplay.text!)!
        let (result, message) = exchange!.trade(player: player!, seller: "Player", color: currentShareButton!.backgroundColor!, count: shares)
        assert (result)
        let newShares = player!.stocks[currentShareButton!.backgroundColor!]!
        if newShares == 0 {
            currentShareButton!.isHidden = true
        }
        else {
            currentShareButton!.setTitle(String(newShares), for: .normal)
        }
        
        mainViewController!.sharesSoldByPlayer(index: index!, color: currentShareButton!.backgroundColor!, money: StockExchange.readMoneyAmountFromMessage(message: message), priceChange: true)
        
        // Update button display
        if exchange!.maxToSell(player: player!, color: currentShareButton!.backgroundColor!) == 0 {
            // Disable the button because it can't be sold
            currentShareButton!.isEnabled = false
            currentShareButton!.alpha = 0.2
        }
        if exchange!.companies[currentShareButton!.backgroundColor!]!.owner?.name != player!.name {
            currentShareButton!.layer.borderWidth = 0
        }
        
        sellRegionView.isHidden = true
        sellRegionTitle.isHidden = false
        currentShareButton = nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sellRegionView.isHidden = true
        playerNameLabel.text = player!.name
        
        let colors = Array(player!.stocks.keys)
        
        for i in 0...player!.stocks.count-1 {
            let stock = player!.stocks[colors[i]]!
            if (stock > 0) {
                playerShareDistributions[i].isHidden = false
                playerShareDistributions[i].center = playerShareSlots[i].center
                playerShareDistributions[i].setTitle(String(player!.stocks[colors[i]]!), for: .normal)
                playerShareDistributions[i].backgroundColor = colors[i]
                playerShareDistributions[i].layer.cornerRadius = 0.2 * playerShareDistributions[i].bounds.size.width
                if exchange!.companies[colors[i]]!.owner?.name == player!.name {
                    playerShareDistributions[i].layer.borderWidth = 10
                    playerShareDistributions[i].layer.borderColor = UIColor.lightGray.cgColor
                }
                
                if exchange!.maxToSell(player: player!, color: colors[i]) == 0 {
                    // Disable the button because it can't be sold
                    playerShareDistributions[i].isEnabled = false
                    playerShareDistributions[i].alpha = 0.2
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class ViewControllerStockCompanyCompany: UIViewController {
    var company : Company? = nil
    var exchange : StockExchange? = nil
    var mainViewController : ViewControllerStockCompanyMain? = nil
    
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyElektro: UILabel!
    @IBOutlet weak var paidAmountTextField: UITextField!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var distributeMoneyButton: UIButton!
    @IBOutlet weak var keepMoneyButton: UIButton!
    
    func setCompanyBeforeSegue(c: Company, e: StockExchange, vc: ViewControllerStockCompanyMain) {
        company = c
        exchange = e
        mainViewController = vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        companyNameLabel.text = company!.name
        companyElektro.text = String(company!.money)
        companyElektro.backgroundColor = company!.color
        
        keepMoneyButton.layer.cornerRadius = 0.1 * keepMoneyButton.bounds.size.height
        keepMoneyButton.layer.borderWidth = 2
        keepMoneyButton.layer.borderColor = UIColor.lightGray.cgColor
        
        distributeMoneyButton.layer.cornerRadius = 0.1 * distributeMoneyButton.bounds.size.height
        distributeMoneyButton.layer.borderWidth = 2
        distributeMoneyButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    
    @IBAction func clickToPayMoney(_ sender: UIButton, forEvent event: UIEvent) {
        let amount = Int(paidAmountTextField.text!)!
        self.view.endEditing(true)

        if (company!.money > amount) {
            company!.money -= amount
            paidAmountTextField.text = ""
            companyElektro.text = String(company!.money)
            for b in mainViewController!.companyElektroButtons {
                if b.backgroundColor! == company!.color {
                    b.setTitle(String(company!.money), for: .normal)
                }
            }
        }
    }
    
    @IBAction func clickToKeepMoney(_ sender: UIButton, forEvent event: UIEvent) {
        let cities = Int(slider.value)
        let amount = exchange!.earnProfit(color: company!.color, cities: cities, distribute: false)
        mainViewController!.companyEarnProfit(playerAmounts: [], color: company!.color, companyAmount: amount.1)
        self.dismiss(animated: true)
    }
    
    @IBAction func clickToDistributeMoney(_ sender: UIButton, forEvent event: UIEvent) {
        let cities = Int(slider.value)
        let amount = exchange!.earnProfit(color: company!.color, cities: cities, distribute: true)
        mainViewController!.companyEarnProfit(playerAmounts: amount.0, color: company!.color, companyAmount: amount.1)
        self.dismiss(animated: true)
    }
    
    
    @IBAction func sliderChangeValue(_ sender: UISlider, forEvent event: UIEvent) {
        sliderLabel.text = String(Int(slider.value))
    }
    
    
    @IBAction func doneEditing(_ sender: UITextField, forEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


