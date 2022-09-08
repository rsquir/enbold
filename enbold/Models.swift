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


struct Note: Codable, Equatable, Identifiable {
    var id = UUID()
    var text: String
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
    let unboldList = ["but", "what"]
    
    func strToAttrStrTextView(str: String) -> NSMutableAttributedString {
        let attrStr = NSMutableAttributedString(string: str)
        
        // set default values for string to make adustments on top of
        attrStr.addAttributes([.font: UIFont(name: fontBold, size: fontSizeTextView)!], range: NSMakeRange(0, str.count))   // default bold font
        
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
                    attrStr.addAttributes([.font: UIFont(name: fontLight, size: fontSizeTextView)], range: s.range)
                }
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
            }
        }
        
        return attrStr
    }
    
    
    func strToAttrStringNavView(str: String) -> AttributedString {
        // code a trim here
        
        
        
        return AttributedString(strToAttrStrTextView(str: str))
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

