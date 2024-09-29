import SwiftUI
import AVFoundation

struct Test: View {
    @State private var userMessage = ""
    @State private var aiResponse = ""
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack {

            ScrollView {
                Text(aiResponse)
                    .padding()
            }
            .padding(.top, 100)
            Text("AiSMR Chat")
                .font(.largeTitle)
                .padding()
            
            TextEditor(text: $userMessage)
                .frame(height: 100)
                .border(Color.gray, width: 1)
                .padding()
            
            Button(action: sendMessage) {
                Text("Send")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
            }
            
            ScrollView {
                

            }
        }
        .onAppear {
            // Optionally initialize audio player here if needed
        }
    }
    
    func sendMessage() {
        guard let url = URL(string: "http://127.0.0.1:5000/chat") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["message": userMessage]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        aiResponse = jsonResponse["response"] as? String ?? "No response"
                        
                        // Play the audio after receiving the response
                        playAudio()
                    }
                }
            }
        }.resume()
    }
    
    func playAudio() {
        guard let audioURL = URL(string: "http://127.0.0.1:5000/audio/output.wav") else { return }
        
        // Fetch the audio data
        URLSession.shared.dataTask(with: audioURL) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to load audio data:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                // Initialize the audio player
                audioPlayer = try AVAudioPlayer(data: data)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error initializing audio player:", error.localizedDescription)
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
