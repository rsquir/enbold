//
//  Models.swift
//  enbold
//
//  Created by Robert Squires on 2022-09-06.
//

import Foundation
import UIKit
import SwiftUI
import NaturalLanguage

class ModelData: ObservableObject {
    @Published var notes: [String] = UserDefaults.standard.array(forKey: "notes") as? [String] ?? ["First note", "Second note", "Third note"] {
        didSet {
            UserDefaults.standard.set(notes, forKey: "notes")
        }
    }
    @Published var nlpOptions: [String: Bool] = UserDefaults.standard.array(forKey: "nlpoptions") as? [String: Bool] ?? ["Interjection": true,
                           "Conjunction": true,
                           "Determiner": true,
                           "Preposition": true] {
        didSet {
            UserDefaults.standard.set(nlpOptions, forKey: "nlpoptions")
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



class AttributedStringMaker {
    @State var nlpOptions: [String: Bool] = ["": false]
    
    // making light vs dark textcolour adjustments
    let currentSystemScheme = UITraitCollection.current.userInterfaceStyle  // i could put this here or in the strtoattrstr but the navview needs to be told to refresh on change so idk
    
    let fontLight = "RobotoFlexNormalNormalNormalNormalNormalNormalNormalNormalNormalDefault-Light"
    let fontBold = "RobotoFlexNormalNormalNormalNormalNormalNormalNormalNormalNormalDefault-Bold"
    
    let fontSizeMain = 15.0
    let fontSizeTextView = 20.0
    
    // regex is leading and trailing whitespace, period, comma, !, ?, beginning and end of line
    // and the word from dict in the middle
    let regexLeftBoundary =   "(^|\\s|\\.|\\,|\\!|\\?)*(?i)\\b"
    let regexRightBoundary = "\\b(\\s|\\.|\\,|\\!|\\?|$)*"
    
    var tagger: NLTagger = NLTagger(tagSchemes: [.lexicalClass])    // this is used for nlp
    
    func strToAttrStrNLP(str: String, size: Double) -> NSMutableAttributedString {
        let attrStr = NSMutableAttributedString(string: str)
        
        // set default values for string to make adustments on top of
        attrStr.addAttributes([.font: UIFont(name: fontBold, size: size)!], range: NSMakeRange(0, str.count))   // default bold font
        
        if (currentSystemScheme == .light) {    // white or black based on dark or light mode for device
            attrStr.addAttributes([.foregroundColor: UIColor.black], range: NSMakeRange(0, str.count))
        } else if (currentSystemScheme == .dark) {
            attrStr.addAttributes([.foregroundColor: UIColor.white], range: NSMakeRange(0, str.count))
        }
        
        tagger.string = str.replacingOccurrences(of: "’", with: "'")
        tagger.enumerateTags(in: str.startIndex..<str.endIndex, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            if let tag = tag {
                if (tag.rawValue == "Interjection" ||
                    tag.rawValue == "Conjunction" ||
                    tag.rawValue == "Determiner" ||
                    tag.rawValue == "Preposition") {
                    attrStr.addAttributes([.font: UIFont(name: fontLight, size: size)], range: NSRange(tokenRange, in: str))
                }
            }
            return true
        }
        
        
        return attrStr
    }
    
    
    func strToAttrStringNavView(str: String) -> AttributedString {
        // trim to 3 lines and 120 chars
        var newStr: String = str
        
        if (str.count > 120) {     // trim to 120th char
            newStr = String(str.prefix(120)) + "..."
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
         
        //return AttributedString(strToAttrStrTextView(str: newStr, size: fontSizeMain))
        return AttributedString(strToAttrStrNLP(str: newStr, size: fontSizeMain))
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

