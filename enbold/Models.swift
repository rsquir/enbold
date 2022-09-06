//
//  Models.swift
//  enbold
//
//  Created by Robert Squires on 2022-09-06.
//

import Foundation


class ModelData: ObservableObject {
    @Published var noteStrings: [String] = UserDefaults.standard.array(forKey: "notes") as? [String] ?? ["First", "Second", "Third"] {
        didSet {
            UserDefaults.standard.set(noteStrings, forKey: "notes")
        }
    }
    
    func saveNoteStrings() {
        UserDefaults.standard.set(noteStrings, forKey: "notes")
    }
}
