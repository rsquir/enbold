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
    @Published var noteStrings: [String] = UserDefaults.standard.array(forKey: "notes") as? [String] ?? ["First note", "Second note", "Third note"] {
        didSet {
            UserDefaults.standard.set(noteStrings, forKey: "notes")
        }
    }
    
    func saveNoteStrings() {
        UserDefaults.standard.set(noteStrings, forKey: "notes")
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
    
    
    // https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}


extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                    ? nsString.substring(with: result.range(at: $0))
                    : ""
            }
        }
    }
}
