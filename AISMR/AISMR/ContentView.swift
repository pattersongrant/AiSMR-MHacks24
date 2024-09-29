import SwiftUI
import Foundation
import AVFAudio

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State var start = false
    @State var userName: String = ""
    var body: some View {
        if start {
            Test()
        } else{
            VStack {
                Text("AiSMR")
                    .font(.system(size: 36, weight: .black))
                Text("Interactive ASMR for the modern day.")
                    .padding()
                Text("Made with Cartesia TTS and Meta Llama-3.")
                    .padding()
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 40)
                    .padding(.top)
                    .padding(.bottom)
                Button("Get Started") {
                    if !userName.isEmpty {
                        start.toggle()
                    }
                }
                .padding()
                .buttonStyle(.bordered)
                .tint(Color.black)
                .font(.title2)

            }
            .padding()
        }
        
    }
    
}

#Preview {
    ContentView()
}
