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
    let currentSystemScheme = UITraitCollection.current.userInterfaceStyle
    
    let fontLight = "RobotoFlexNormalNormalNormalNormalNormalNormalNormalNormalNormalDefault-Light"
    let fontBold = "RobotoFlexNormalNormalNormalNormalNormalNormalNormalNormalNormalDefault-Bold"
    
    let fontSizeMain = 15.0
    let fontSizeTextView = 15.0
    
    
    let unboldList = ["but", "what"]
    
    func strToAttrStrTextView(str: String) -> NSMutableAttributedString {
        let attrStr = NSMutableAttributedString(string: str)
        
        attrStr.addAttributes([.font: UIFont(name: fontBold, size: fontSizeTextView)!], range: NSMakeRange(0, str.count))
        
        if (currentSystemScheme == .light) {
            attrStr.addAttributes([.foregroundColor: UIColor.black], range: NSMakeRange(0, str.count))
        } else if (currentSystemScheme == .dark) {
            attrStr.addAttributes([.foregroundColor: UIColor.white], range: NSMakeRange(0, str.count))
        }
        
        return attrStr
    }
    
    
    func strToAttrStringNavView(str: String) -> AttributedString {
        // code a trim here
        
        return AttributedString(strToAttrStrTextView(str: str))
    }
}
