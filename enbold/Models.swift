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
    @Published var notes: [String] = UserDefaults.standard.array(forKey: "notes") as? [String] ?? ["This is the first note. This app allows you to focus on the important words by highlighting them.", "Second note", "Third note"] {
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



class AttributedStringMaker: ObservableObject {
    // Interjection, Conjunction, Determiner, Preposition, Noun, Verb, Adjective, Adverb, Pronoun, Particle, Preposition, Conjunction
    
    @Published var nlpOptions = [NLPOption]() {
        didSet {
            save()
        }
    }
    
    // making light vs dark textcolour adjustments
    @Environment(\.colorScheme) var colorScheme
    let currentSystemScheme = UITraitCollection.current.userInterfaceStyle  // i could put this here or in the strtoattrstr but the navview needs to be told to refresh on change so idk
    
    let fontLight = "RobotoFlexNormalNormalNormalNormalNormalNormalNormalNormalNormalDefault-Light"
    let fontBold = "RobotoFlexNormalNormalNormalNormalNormalNormalNormalNormalNormalDefault-Bold"
    
    let fontSizeMain = 15.0
    let fontSizeTextView = 20.0
    let fontSizeNLPOption = 16.0
    
    var tagger: NLTagger = NLTagger(tagSchemes: [.lexicalClass])    // this is used for nlp
    
    
    init() {
        load()
    }
    
    
    func strToAttrStrNLP(str: String, size: Double) -> NSMutableAttributedString {
        let attrStr = NSMutableAttributedString(string: str)
        
        // set default values for string to make adustments on top of
        attrStr.addAttributes([.font: UIFont(name: fontBold, size: size)!], range: NSMakeRange(0, str.count))   // default bold font
        
        if (currentSystemScheme == .light) {    // white or black based on dark or light mode for device
            attrStr.addAttributes([.foregroundColor: UIColor.black], range: NSMakeRange(0, str.count))
        } else if (currentSystemScheme == .dark) {
            attrStr.addAttributes([.foregroundColor: UIColor.white], range: NSMakeRange(0, str.count))
        }
        
        
        if (colorScheme == .dark) {
            // thia doesn't work
        }
        
        tagger.string = str.replacingOccurrences(of: "’", with: "'")
        tagger.enumerateTags(in: str.startIndex..<str.endIndex, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            if let tag = tag {
                for option in nlpOptions {
                    if (tag.rawValue == option.lex && option.on) {
                        attrStr.addAttributes([.font: UIFont(name: fontLight, size: size)], range: NSRange(tokenRange, in: str))
                    }
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
        return AttributedString(strToAttrStrNLP(str: newStr.trimmingCharacters(in: .whitespacesAndNewlines), size: fontSizeMain))
    }
    
    
    func strToAttrStringNLPOption(str: String) -> AttributedString {
        return AttributedString(strToAttrStrNLP(str: str, size: fontSizeNLPOption))
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
    
    
    // got solution to saving structs in array from this link:
    // https://gist.github.com/enomoto/629a85bd4e82902057c0b614602a71b3
    func save() {
        let data = nlpOptions.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(data, forKey: "nlpoptions")
    }

    func load() {
        guard let encodedData = UserDefaults.standard.array(forKey: "nlpoptions") as? [Data] else {
            nlpOptions =
            [NLPOption(lex: "Interjection", on: true),
             NLPOption(lex: "Conjunction", on: true),
             NLPOption(lex: "Determiner", on: true),
             NLPOption(lex: "Preposition", on: true),
             NLPOption(lex: "Pronoun", on: true),
             NLPOption(lex: "Noun", on: false),
             NLPOption(lex: "Verb", on: false),
             NLPOption(lex: "Adjective", on: false),
             NLPOption(lex: "Adverb", on: false),
             NLPOption(lex: "Particle", on: false)]
            return
        }

        
        nlpOptions = encodedData.map { try! JSONDecoder().decode(NLPOption.self, from: $0) }
    }

}


struct NLPOption: Codable {
    var id = UUID()
    
    var lex: String
    var on: Bool
}
