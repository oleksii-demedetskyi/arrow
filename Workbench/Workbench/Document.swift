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

struct Root<T: View>: View {
    @ObservedObject var store: Store
    let connect: (AppState, @escaping (Action) -> ()) -> T
    
    var body: T {
        connect(store.state, store.dispatch(action:))
    }
}

class Command {
    let action: () -> ()
    
    func perform() {
        self.action()
    }
    
    init(action: @escaping () -> ()) {
        self.action = action
    }
    
    static let nop = Command { }
    
    static func bind(_ action: Action, to dispatch: @escaping (Action) -> ()) -> Command {
        return Command {
            dispatch(action)
        }
    }
}

class Document: NSDocument {
    let store = Store()
    
    var body: some View {
        Root(store: store) { state, dispatch in
            Editor(lines: state.lines.enumerated().map { line in
                Line(
                    id: line.offset,
                    text: line.element,
                    select: .bind(HighlightLine(index: line.offset), to: dispatch),
                    isSelected: state.highlightedLine == line.offset
                )}
            )
        }
    }
    
    override func makeWindowControllers() {
        // Create the window and set the content view.
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.contentView = NSHostingView(rootView: body)
        let windowController = NSWindowController(window: window)
        self.addWindowController(windowController)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        let text = String(data: data, encoding: .utf8)!
        store.dispatch(action: RenderFile(contents: text))
    }
    
    
}

