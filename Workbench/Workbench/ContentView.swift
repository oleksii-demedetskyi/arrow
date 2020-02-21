import SwiftUI

struct LineView: View, Identifiable {
    let id: Int
    let text: String
    
    @State var selected: Bool = false
    
    var color: some View {
        if (selected) {
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
        .onTapGesture {
            self.selected = !self.selected
        }
        .background(self.color)
    }
}

struct ContentView: View {
    let lines: [LineView]
    var body: some View {
        List(lines) { $0 }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(lines: [
            LineView(id: 1, text: "action Increment"),
            LineView(id: 2, text: "action Decrement"),
            LineView(id: 300, text: "state Counter: Int = 0"),
        ])
    }
}
