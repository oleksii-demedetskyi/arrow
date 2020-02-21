import SwiftUI

struct Line: View, Identifiable {
    let id: Int
    let text: String
    let select: Command
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
            Text(text)
            Spacer()
        }
        .font(.system(.body, design: .monospaced))
        .onTapGesture(perform: self.select.perform)
        .background(self.color)
    }
}

struct Editor: View {
    let lines: [Line]
    
    var body: some View {
        List(lines) {
            $0
        }
        .listRowInsets(.init(top: 0, leading: 0, bottom: 50, trailing: 0))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Editor(lines: [
            Line(id: 1, text: "action Increment", select: .nop, isSelected: true),
            Line(id: 2, text: "action Decrement", select: .nop, isSelected: false),
            Line(id: 300, text: "state Counter: Int = 0", select: .nop, isSelected: false)
        ])
    }
}
