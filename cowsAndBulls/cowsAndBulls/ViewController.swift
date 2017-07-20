//
//  ViewController.swift
//  cowsAndBulls
//
//  Created by Ben Perkins on 7/19/17.
//  Copyright © 2017 Ben Perkins. All rights reserved.
//

import Cocoa
import GameplayKit

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBAction func buttonPressed(_ sender: NSButton) {
        processGuess()
    }
    @IBAction func textFieldAction(_ sender: NSTextField) {
        processGuess()
    }
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var guessField: NSTextField!
    var guesses: [String] = []
    var answer = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetGame()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        if(obj.object as! NSTextField == guessField) {
            giveValidityHint()
        }
    }
    
    func processGuess() {
        if(isValid(guess: guessField.stringValue)) {
            guesses.append(guessField.stringValue)
            tableView.reloadData()
            guessField.stringValue = ""
            if getScore(for: guessField.stringValue).contains("4b") {
                let alert = NSAlert()
                alert.messageText = "Game over!"
                alert.informativeText = "You won in \(guesses.count) turns"
                alert.alertStyle = .informational
                alert.addButton(withTitle: "Play again")
                alert.addButton(withTitle: "Quit")
                if(alert.runModal() == NSAlertFirstButtonReturn) {
                    resetGame()
                } else {
                    exit(0)
                }
            }
        }
    }
    
    func giveValidityHint() {
        if(!isValid(guess: guessField.stringValue)) {
            guessField.textColor = NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1)
        } else {
            guessField.textColor = NSColor(cgColor: .black)
        }
    }
    
    func isValid(guess: String) -> Bool {
        var characters: Set<Character> = []
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        if guesses.contains(guess) {
            return false
        }
        if guess.rangeOfCharacter(from: invalidCharacters) == nil {
            for character in guess.characters {
                characters.insert(character)
            }
        }
        return characters.count == 4
    }
    
    func getScore(for guess: String) -> String {
        var cows = 0
        var bulls = 0
        for (i, c) in guess.characters.enumerated() {
            if answer[answer.index(answer.startIndex, offsetBy: i)] == c {
                bulls += 1
            } else if answer.contains(String(c)) {
                cows += 1
            }
        }
        return "\(bulls)b\(cows)c"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return guesses.count
    }
    
    func resetGame() {
        let randomArray = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: Array("0123456789".characters))
        answer = randomArray[0...3].map({"\($0)"}).joined()
        //guessField.placeholderString = answer
        guessField.stringValue = ""
        guesses = []
        tableView.reloadData()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as? NSTableCellView
        if(tableColumn?.title == "Guess") {
            cell?.textField?.stringValue = guesses[row]
        } else if(tableColumn?.title == "Result") {
            cell?.textField?.stringValue = getScore(for: guesses[row])
        }
        return cell
    }


}

