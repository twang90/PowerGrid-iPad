//
//  ViewController.swift
//  PowerGrid-iPad
//
//  Created by Tiancong Wang on 8/27/18.
//  Copyright © 2018 Justin&Nick. All rights reserved.
//

import UIKit

let maxPlayers = 6
var players : [Player] = Array(repeating: Player(), count: maxPlayers)

class ViewControllerBotMain: UIViewController {
    // Static variables
    static var slotButtonStorage : [UIButton] = []
    static var colorButtonStorage : [UIButton] = []
    
    // Members
    var colorButtonLoc : [CGPoint] = []
    var currentBot : Int = -1
    
    // Outlets
    @IBOutlet var colorButtons: [UIButton]!
    @IBOutlet var slotButtons: [UIButton]!
    @IBOutlet var slotViews: [UIView]!
    
    @IBOutlet var slotTitleLabels: [UILabel]!
    @IBOutlet var slotEarnButtons: [UIButton]!
    @IBOutlet var slotSpendButtons: [UIButton]!
    @IBOutlet var slotOverviewButtons: [UIButton]!
    @IBOutlet var slotElektroLabels: [UILabel]!
    @IBOutlet var slotInputTextFields: [UITextField]!
    @IBOutlet weak var botDisplayView: UIView!
    @IBOutlet var botDisplayLabels: [UILabel]!
    @IBOutlet var botDisplayButtons: [UIButton]!
    
    @IBOutlet weak var moneyAnimationView: UIView!
    @IBOutlet weak var moneyAnimationValueLabel: UILabel!
    @IBOutlet weak var moneyBankLocView: UIView!
    
    // Util functions
    func setupButton(button: UIButton) {
        button.isHidden = false
        button.isEnabled = true
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 0.2 * button.bounds.size.width
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
    }
    
    func _initSlot(index: Int) {
        // Initialze the view
        // Disable the button
        slotButtons[index].isEnabled = false
        slotButtons[index].isHidden = true
        //slotButtons[index].setTitle("", for: .normal)
        
        // Title
        slotTitleLabels[index].isHidden = false
        if players[index] is PGBot {
            slotTitleLabels[index].text = "Bot "+String(index+1)
        }
        else {
            slotTitleLabels[index].text = "Human "+String(index+1)
        }
        
        slotTitleLabels[index].textColor = .white
        
        // setup buttons
        setupButton(button:slotEarnButtons[index])
        setupButton(button:slotSpendButtons[index])
        
        // Setup Input
        slotInputTextFields[index].isHidden = false
        
        // setup overviews
        slotElektroLabels[index].isHidden = false
        slotElektroLabels[index].textColor = .white
        setupButton(button:slotOverviewButtons[index])
    }
    
    func initBot(index: Int) {
        // Initialize a bot object
        players[index] = PGBot()
        // setup view body
        slotOverviewButtons[index].setTitle(String(players[index].money), for: .normal)
        
        _initSlot(index: index)
    }
    
    func initPlayer(index: Int) {
        players[index] = Player()
        // setup view body
        slotOverviewButtons[index].setTitle("Hold to view your Elektro", for: .normal)
        slotOverviewButtons[index].titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        _initSlot(index: index)
    }
    
    func initColors() {
        // Save original location of the button
        colorButtonLoc.removeAll()
        for i in 0...colorButtons.count-1 {
            colorButtonLoc.append(colorButtons[i].center)
            colorButtons[i].layer.cornerRadius = 0.5 * colorButtons[i].bounds.size.width
        }
    }
    
    func initSlots() {
        for i in 0...slotButtons.count-1 {
            slotButtons[i].layer.borderWidth = 2
        }
    }
    
    // Action for color buttons
    @IBAction func dragToSelectColor(_ sender: UIButton, forEvent event: UIEvent) {
        if let center = event.allTouches?.first?.location(in: self.view) {
            sender.center = center
        }
    }
    
    @IBAction func releaseColorButton(_ sender: UIButton, forEvent event: UIEvent) {
        for i in 0...slotViews.count-1 {
            if (slotViews[i].frame.intersects(sender.frame)){
                // Sender color button back
                sender.center = colorButtonLoc[colorButtons.index(of: sender)!]
                if slotButtons[i].title(for: .normal) == "Empty" {
                    // Nothing happens, just go back
                    break
                }
                // disable the color button and change color
                sender.alpha = 0.2
                sender.isEnabled = false
                
                // Color the view
                if (slotViews[i].backgroundColor == nil) {
                    // Paint the button if never painted before
                    slotViews[i].backgroundColor = sender.backgroundColor
                }
                else {
                    // Re-paint the bot and restore the old color
                    for b in colorButtons {
                        if (b.backgroundColor == slotViews[i].backgroundColor) {
                            assert(b.isEnabled == false)
                            b.alpha = 1
                            b.isEnabled = true
                            break
                        }
                    }
                    slotViews[i].backgroundColor = sender.backgroundColor
                }
                
                if (slotButtons[i].title(for: .normal)?.contains("Bot"))! {
                    //Generate a bot to replace human player
                    initBot(index:i)
                }
                else if (slotButtons[i].title(for: .normal)?.contains("Human"))! {
                    initPlayer(index:i)
                }
                
                break
            }
            
        }
    }
    
    // Action for slot buttons
    @IBAction func clickToToggleSlotType(_ sender: UIButton, forEvent event: UIEvent) {
        let title : String = sender.title(for: .normal)!
        if sender.backgroundColor != nil && sender.backgroundColor != .white {
            
            assert (title != "Empty")
            if title.contains("Bot") {
                self.performSegue(withIdentifier: "ToBot", sender: sender)
            }
            else if title.contains("Human") {
                self.performSegue(withIdentifier: "ToHuman", sender: sender)
            }
            return
        }
        
        if (title.contains("Empty")) {
            sender.setTitle("Human "+String(slotButtons.index(of: sender)!+1), for: .normal)
            sender.setTitleColor(.blue, for: .normal)
        }
        else if title.contains("Human") {
            sender.setTitle("Bot "+String(slotButtons.index(of: sender)!+1), for: .normal)
            sender.setTitleColor(.blue, for: .normal)
        }
        else if title.contains("Bot") {
            sender.setTitle("Empty", for: .normal)
            sender.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    func addMoneyAnimation(value: Int, add: Bool, dest: Int) {
        let destination = self.slotViews[dest].convert(self.slotOverviewButtons[dest].center, to: self.moneyAnimationView.superview)
        
        moneyAnimationView.layer.cornerRadius = 0.5 * moneyAnimationView.bounds.size.width
        moneyAnimationView.layer.borderWidth = 5
        moneyAnimationView.layer.borderColor = UIColor.black.cgColor
        moneyAnimationValueLabel.text = String(value)
        moneyAnimationView.alpha = 1.0
        
        let needRedisplayBot = !botDisplayView.isHidden
        botDisplayView.isHidden = true
        
        if add {
           moneyAnimationView.center = moneyBankLocView.center
            moneyAnimationView.isHidden = false
            
            UIView.animate(withDuration: 1.0, animations: {() -> Void in
                self.moneyAnimationView.center = destination
                self.moneyAnimationView.alpha = 0.0
            }, completion: {(true) -> Void in
                self.moneyAnimationView.isHidden = true
                if players[dest] is PGBot {
                    self.slotOverviewButtons[dest].setTitle(String(players[dest].money), for:.normal)
                    if (needRedisplayBot){
                        self.botDisplayView.isHidden = false
                    }
                }
            })
        }
        else {
            moneyAnimationView.center = destination
            moneyAnimationView.isHidden = false
            
            UIView.animate(withDuration: 1.0, animations: {() -> Void in
                self.moneyAnimationView.center = self.moneyBankLocView.center
                self.moneyAnimationView.alpha = 0.0
            }, completion: {(true) -> Void in
                self.moneyAnimationView.isHidden = true
                if players[dest] is PGBot {
                    self.slotOverviewButtons[dest].setTitle(String(players[dest].money), for:.normal)
                    if (needRedisplayBot){
                        self.botDisplayView.isHidden = false
                    }
                }
            })
        }
    }
    @IBAction func changeMoney(_ sender: UIButton, forEvent event: UIEvent) {
        if sender.title(for: .normal) == "Earn" {
            let index = slotEarnButtons.index(of: sender)!
            if let result = Int(slotInputTextFields[index].text!) {
                players[index].money += result
                slotInputTextFields[index].text = ""
                addMoneyAnimation(value: result, add: true, dest: index)
            }
        }
        else if sender.title(for: .normal) == "Spend" {
            let index = slotSpendButtons.index(of: sender)!
            if let result = Int(slotInputTextFields[index].text!) {
                players[index].money -= result
                slotInputTextFields[index].text = ""
                addMoneyAnimation(value: result, add: false, dest: index)
            }
        }
        self.view.endEditing(true)
        
    }
    
    @IBAction func doneEditing(_ sender: UITextField, forEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func showMoneyStart(_ sender: UIButton, forEvent event: UIEvent) {
        let index = slotOverviewButtons.index(of:sender)!
        if !(players[index] is PGBot) {
            sender.setTitle(String(players[index].money), for: .normal)
        }
    }
    
    @IBAction func showMoneyEnd(_ sender: UIButton, forEvent event: UIEvent) {
        let index = slotOverviewButtons.index(of:sender)!
        if let bot = players[index] as? PGBot {
            if botDisplayView.isHidden {
                botDisplayView.isHidden = false
                for i in 0...botDisplayLabels.count-1{
                    botDisplayLabels[i].text = descriptions[i][bot.properties[i]]
                }
                currentBot = index
            }
            else {
                botDisplayView.isHidden = true
                currentBot = -1
            }
        }
        else {
            sender.setTitle("Hold to view your Elektro", for: .normal)
            sender.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        }
    }
    
    
    @IBAction func reset(_ sender: UIButton, forEvent event: UIEvent) {
        for b in colorButtons {
            b.isEnabled = true
            b.alpha = 1.0
        }
        
        for i in 0...slotButtons.count-1 {
            slotViews[i].backgroundColor = nil
            slotTitleLabels[i].isHidden = true
            slotEarnButtons[i].isHidden = true
            slotSpendButtons[i].isHidden = true
            slotElektroLabels[i].isHidden = true
            slotInputTextFields[i].isHidden = true
            slotButtons[i].setTitle("Empty", for: .normal)
            slotButtons[i].setTitleColor(.lightGray, for: .normal)
            slotButtons[i].isHidden = false
            slotButtons[i].isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initColors()
        initSlots()
        
        // Restore previous storage
        if (ViewControllerBotMain.slotButtonStorage.count != 0) {
            for i in 0...ViewControllerBotMain.slotButtonStorage.count-1 {
                slotButtons[i].backgroundColor = ViewControllerBotMain.slotButtonStorage[i].backgroundColor
                slotButtons[i].setTitle(ViewControllerBotMain.slotButtonStorage[i].title(for: .normal), for: .normal)
                slotButtons[i].setTitleColor(ViewControllerBotMain.slotButtonStorage[i].titleColor(for: .normal), for: .normal)
                
            }
            ViewControllerBotMain.slotButtonStorage.removeAll(keepingCapacity: false)
        }
        if (ViewControllerBotMain.colorButtonStorage.count != 0) {
            for i in 0...ViewControllerBotMain.colorButtonStorage.count-1 {
                colorButtons[i].alpha = ViewControllerBotMain.colorButtonStorage[i].alpha
                colorButtons[i].isEnabled = ViewControllerBotMain.colorButtonStorage[i].isEnabled
            }
            ViewControllerBotMain.colorButtonStorage.removeAll(keepingCapacity: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // For segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sender_button = sender as? UIButton {
            if let dest = segue.destination as? ViewControllerPopOver {
                assert (currentBot != -1)
               let index = botDisplayButtons.index(of:sender_button)!
                let bot = players[currentBot] as! PGBot
                dest.display(index: index, content: bot.properties[index])
                return
            }
        }
        assert(false)
    }
    
}

class ViewControllerPopOver: UIViewController {
    var index : Int = -1
    var content : Int = -1
    func display(index: Int, content: Int) {
        self.index = index
        self.content = content
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        assert (index != -1)
        assert (content != -1)
        titleLabel.text = titles[index]
        overviewLabel.text = descriptions[index][content]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

