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


// hardcoding to a light or dark colour (likely light) because i can't have an environmental
// variable call with this global class--called too early
class AttributedStringMaker {
    let fontLight = "RobotoFlexNormalNormalNormalNormalNormalNormalNormalNormalNormalDefault-Light"
    let fontBold = "RobotoFlexNormalNormalNormalNormalNormalNormalNormalNormalNormalDefault-Bold"
   
    let fontSizeMain = 15.0
    let fontSizeTextView = 15.0
    
    
    let unboldList = ["but", "what"]
    
    func strToAttrStrTextView(str: String) -> NSMutableAttributedString {
        let attrStr = NSMutableAttributedString(string: str)
        
        attrStr.addAttributes([.font: UIFont(name: fontBold, size: fontSizeTextView)!], range: NSMakeRange(0, str.count))
        
        attrStr.addAttributes([.foregroundColor: UIColor.white], range: NSMakeRange(0, str.count))
        
        return attrStr
    }
    
    //will need to trim new lines for main view, do this here? i think so
    func strToAttrStringNavView(str: String) -> NSMutableAttributedString {
        return strToAttrStrTextView(str: str)
    }
}
