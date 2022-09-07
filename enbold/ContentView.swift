//
//  ContentView.swift
//  enbold
//
//  Created by Robert Squires on 2022-09-06.
//

import SwiftUI

// made global, don't know how to send this to UITextView Coordinator
var attrStringMaker = AttributedStringMaker()

struct ContentView: View {
    @ObservedObject var modelData = ModelData()
    
    var body: some View {
        NavigationView {
            List(0..<modelData.noteStrings.count) { index in
                NavigationLink(destination: NoteView(str: $modelData.noteStrings[index])) {
                    NoteRow(str: $modelData.noteStrings[index])
                }
            }
        }
    }
}

struct NoteView: View {
    @Binding var str: String
    
    var body: some View {
        TextViewEnbold(str: $str)
    }
}


struct NoteRow: View {
    @Binding var str: String
    
    var body: some View {
        Text(str)
        
        // can't seem to use an attributed string with Text class, will come back to this
        //Text(attrStringMaker.strToAttrStringNavView(str: str).attributedSubstring(from: NSMakeRange(0, str.count)))
    }
}


// https://stackoverflow.com/questions/57597060/swiftui-uitextview-coordinator-not-working
struct TextViewEnbold: UIViewRepresentable {
    @Binding var str: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let textViewEnbold = UITextView()
        textViewEnbold.delegate = context.coordinator
        
        textViewEnbold.isScrollEnabled = true
        textViewEnbold.isEditable = true
        textViewEnbold.isUserInteractionEnabled = true
        
        //textViewEnbold.backgroundColor = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0)
        
        let attrString = attrStringMaker.strToAttrStrTextView(str: str)
        textViewEnbold.attributedText = attrString
        
        return textViewEnbold
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // code
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewEnbold
        
        init(_ uiTextView: TextViewEnbold) {
            self.parent = uiTextView
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.str = textView.text
            
            let cursor = textView.selectedTextRange
            
            textView.attributedText = attrStringMaker.strToAttrStrTextView(str: textView.text)
            
            textView.selectedTextRange = cursor
        }
    }
}


// much needed extension for storing [String] with AppStorage
// https://stackoverflow.com/questions/63166706/how-to-store-nested-arrays-in-appstorage-for-swiftui
extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
