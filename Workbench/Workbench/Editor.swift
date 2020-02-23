import SwiftUI


struct Opacity: ViewModifier {
    private let opacity: Double
    init(_ opacity: Double) {
        self.opacity = opacity
    }

    func body(content: Content) -> some View {
        content.opacity(opacity)
    }
}

extension AnyTransition {
    static func repeating<T: ViewModifier>(from: T, to: T, duration: Double = 0.5) -> AnyTransition {
       .asymmetric(
            insertion: AnyTransition
                .modifier(active: from, identity: to)
                .animation(Animation.easeInOut(duration: duration).repeatForever())
                .combined(with: .opacity),
            removal: .opacity
        )
    }
}

struct Cursor: View {
    var body: some View {
        Rectangle().frame(width: 4)
            //.transition(.repeating(from: Opacity(0), to: Opacity(1)))
    }
}

struct Line: View, Identifiable {
    let id: Int
    let text: String
    let select: Command
    let cursorOffset: String.Index
    let isSelected: Bool
    
    
    var color: some View {
        if (isSelected) {
            return Color(.darkGray)
        } else {
            return Color(.clear)
        }
    }
    
    var body: some View {
        HStack {
            HStack {
                Spacer()
                Text("\(id)").foregroundColor(.gray)
            }
            .frame(width: 40)
            if (isSelected) {
                HStack(spacing: -2) {
                    Text(text[..<cursorOffset])
                    Cursor()
                    Text(text[cursorOffset...])
                }
            } else {
                Text(text)
            }
            Spacer()
        }
        .padding(.vertical, 2)
        .font(.system(.body, design: .monospaced))
        .contentShape(Rectangle())
        .onTapGesture { self.select.perform() }
        .background(self.color)
    }
}

struct Editor: View {
    let lines: [Line]
    
    var body: some View {
        // This is slow but with 0 spacing
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(lines) {
                    $0
                }
            }
            Spacer(minLength: 200)
        }
        
        // This is fast but list cannot handle 0 spacing.
        // List(lines.indices) { self.lines[$0] }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Editor(lines: [
            Line(id: 1, text: "action Increment", select: .nop, cursorOffset: "action Increment".index("".startIndex, offsetBy: 5),isSelected: true),
            Line(id: 2, text: "action Decrement", select: .nop, cursorOffset: "".startIndex, isSelected: false),
            Line(id: 300, text: "state Counter: Int = 0", select: .nop, cursorOffset: "".startIndex, isSelected: false)
        ])
    }
}
