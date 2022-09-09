//
//  Models.swift
//  enbold
//
//  Created by Robert Squires on 2022-09-06.
//

import Foundation
import UIKit
import SwiftUI


class ModelData: ObservableObject {
    @Published var notes: [String] = UserDefaults.standard.array(forKey: "notes") as? [String] ?? ["First note", "Second note", "Third note"] {
        didSet {
            UserDefaults.standard.set(notes, forKey: "notes")
        }
    }
    
    let notesBeginnings = ["First note",
                           "Second note",
                           "Third note",
                           "Fourth note",
                           "Fifth note",
                           "Sixth note",
                           "Seventh note",
                           "Eighth note",
                           "Nineth note",
                           "Tenth note",
                           "Another note"]
    
    func saveNoteStrings() {
        UserDefaults.standard.set(notes, forKey: "notes")
    }
    
    func addNote() {
        if (notes.count > notesBeginnings.count - 1) {
            notes.append(notesBeginnings[10])
        } else {
            notes.append(notesBeginnings[notes.count])
        }
    }
}


// hardcoding to a light or dark colour (likely light), environment colorScheme !working
class AttributedStringMaker {
    // making light vs dark textcolour adjustments
    let currentSystemScheme = UITraitCollection.current.userInterfaceStyle  // i could put this here or in the strtoattrstr but the navview needs to be told to refresh on change so idk
    
    let fontLight = "RobotoFlexNormalNormalNormalNormalNormalNormalNormalNormalNormalDefault-Light"
    let fontBold = "RobotoFlexNormalNormalNormalNormalNormalNormalNormalNormalNormalDefault-Bold"
    
    let fontSizeMain = 15.0
    let fontSizeTextView = 15.0
    
    let regexLeftBoundary = "(^|\\s|\\.|\\!|\\?)*(?i)\\b"
    let regexRightBoundary = "\\b(\\s|\\.|\\!|\\?|$)*"
    
    // made this list based off https://en.wikipedia.org/wiki/Most_common_words_in_English
    // maybe not comments are ranked from 1 to n; 1 being most important
    let unboldList = ["a",
                      "about",      // maybe not (2)
                      "after",
                      "also",
                      "an",
                      "and",        // maybe not (1)
                      "any",
                      "as",
                      "at",
                      "back",
                      "be",
                      "because",    // maybe not (2)
                      "but",
                      "by",
                      "can",
                      "come",       // maybe not (2)
                      "could",
                      "for",
                      "from",
                      "get",
                      "go",
                      "have",
                      "he",
                      "how",
                      "if",         // maybe not (1)
                      "in",
                      "into",
                      "it",
                      "it’s",       // test this
                      "its",
                      "just",
                      "know",
                      "like",
                      "make",
                      "most",
                      "of",
                      "on",
                      "or",         // maybe not (1)
                      "so",
                      "some",
                      "take",
                      "than",
                      "then",
                      "that",
                      "the",
                      "their",
                      "there",
                      "these",
                      "this",
                      "to",
                      "want",
                      "well",
                      "what",
                      "when",
                      "which",
                      "will",       // maybe not (1)
                      "with",
                      "would",
                      "use"]
    
    func strToAttrStrTextView(str: String, size: Double) -> NSMutableAttributedString {
        let attrStr = NSMutableAttributedString(string: str)
        
        // set default values for string to make adustments on top of
        attrStr.addAttributes([.font: UIFont(name: fontBold, size: size)!], range: NSMakeRange(0, str.count))   // default bold font
        
        if (currentSystemScheme == .light) {    // white or black based on dark or light mode for device
            attrStr.addAttributes([.foregroundColor: UIColor.black], range: NSMakeRange(0, str.count))
        } else if (currentSystemScheme == .dark) {
            attrStr.addAttributes([.foregroundColor: UIColor.white], range: NSMakeRange(0, str.count))
        }
        
        
        // range of word with regex
        for ub in unboldList {
            do {
                let regex = try NSRegularExpression(pattern: regexLeftBoundary + ub + regexRightBoundary)
                for s in regex.matches(in: str, range: NSMakeRange(0, str.count)) {
                    attrStr.addAttributes([.font: UIFont(name: fontLight, size: size)], range: s.range)
                }
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
            }
        }
        
        return attrStr
    }
    
    
    func strToAttrStringNavView(str: String) -> AttributedString {
        // trim to 3 lines and 88 chars
        var newStr: String = str
        
        // trim to 88th char
        if (str.count > 88) {
            newStr = String(str.prefix(88))
        }
        
        // get array of regex \n, then on index 0 truncate str
        do {
            let regex = try NSRegularExpression(pattern: "\\n")
            let matches = regex.matches(in: str, range: NSMakeRange(0, str.count))
            if (matches.count > 2) {
                newStr = String(newStr.prefix(matches[2].range.location))
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        
        return AttributedString(strToAttrStrTextView(str: newStr, size: fontSizeMain))
    }
    
    
    // didn't use this function, keeping it just in case
    // seems like apple won't allow a different font for navtitle
    func getNavTitle() -> AttributedString {
        let str = "enbold"
        let attrStr = NSMutableAttributedString(string: str)
        
        attrStr.addAttributes([.font: UIFont(name: fontLight, size: 20.0)], range: NSMakeRange(0, 2))
        attrStr.addAttributes([.font: UIFont(name: fontBold, size: 10.0)], range: NSMakeRange(2, 4))
        
        return AttributedString(attrStr)
    }
}

