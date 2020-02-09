import SwiftUI

struct ContentView: View {
    var text: String
    var body: some View {
        ScrollView {
            ForEach(text.components(separatedBy: CharacterSet.newlines), id: \.self) { substring in
                Text(substring).multilineTextAlignment(.leading)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(text: "action Increment")
    }
}
