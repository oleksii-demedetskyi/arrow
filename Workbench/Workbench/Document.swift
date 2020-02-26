//
//  Document.swift
//  Workbench
//
//  Created by Alexey Demedetskii on 2/9/20.
//  Copyright © 2020 Arrow. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine
import Parser

class Compiler: Subscriber {
    private let queue = DispatchQueue(label: "compiler")
    
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    var textHash: Int = 0
    
    func receive(_: ()) -> Subscribers.Demand {
        //queue.async {
            DispatchQueue.main.async {
                let text = self.store.state.lines.joined(separator: "\n")
                guard text.hashValue != self.textHash else { return }
                self.textHash = text.hashValue
                
                let lexems = Lexer(string: text).scan()
                self.store.dispatch(action: LexerDidSuccess(lexems: lexems))
            }
        //}
        
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Never>) {}
    
    let store: Store
    
    init(store: Store) {
        self.store = store
        store.objectWillChange.subscribe(self)
    }
}

let sharedStore = Store()


struct LexemesList: View {
    let lexems: [Lexeme]
    var body: some View {
        List {
            ForEach(lexems.indices, id: \.self) { idx in
                LexemeView(lexeme: self.lexems[idx])
            }
        }
    }
}

class Document: NSDocument {
    // Use proper init
    let store = sharedStore
    let compiler = Compiler(store: sharedStore)
    
    var body: some View {
        Root(store: store) { state, dispatch in
            HStack(alignment: .top) {
                LexemesList(lexems: state.lexems)
                Editor(lines: state.lines.enumerated().map { line in
                    Line(
                        id: line.offset,
                        text: line.element,
                        select: .bind(HighlightLine(index: line.offset), to: dispatch),
                        cursorOffset: state.cursorOffset,
                        isSelected: state.highlightedLine == line.offset
                    )}
                )
            }
        }
    }
    
    override func makeWindowControllers() {
        // Create the window and set the content view.
        let window = Window(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.store = store
        window.contentView = NSHostingView(rootView: body)
        let windowController = NSWindowController(window: window)
        self.addWindowController(windowController)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        let text = String(data: data, encoding: .utf8)!
        store.dispatch(action: RenderFile(contents: text))
    }
}

class Window: NSWindow {
    var store: Store!
    
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }
    
    override func moveUp(_ sender: Any?) {
        store.dispatch(action: MoveLineUp())
    }
    
    override func moveDown(_ sender: Any?) {
        store.dispatch(action: MoveLineDown())
    }
    
    override func moveLeft(_ sender: Any?) {
        store.dispatch(action: MoveLeft())
    }
    
    override func moveRight(_ sender: Any?) {
        store.dispatch(action: MoveRight())
    }
    
    override func insertNewline(_ sender: Any?) {
        store.dispatch(action: InsertNewLine())
    }
    
    override func insertText(_ insertString: Any) {
        guard let text = insertString as? String else {
            assertionFailure("WTF Appkit?")
            return
        }
        
        store.dispatch(action: InsertText(text: text))
    }
    
    override func deleteBackward(_ sender: Any?) {
        store.dispatch(action: DeleteBackward())
    }
}
