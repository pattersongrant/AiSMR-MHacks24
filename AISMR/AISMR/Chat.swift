//
//  Chat.swift
//  AISMR
//
//  Created by Grant Patterson on 9/29/24.
//

import SwiftUI
import AVFAudio

struct Chat: View {
    @State private var audioPlayer: AVAudioPlayer?
    var userName: String
    var body: some View {
        Text("Hello, \(userName)!")
        Button(action: {
            playAudio()
        }) {
            Text("Play Audio")
                .font(.system(size: 24, weight: .bold))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    func playAudio() {
        guard let url = Bundle.main.url(forResource: "newoutput", withExtension: "wav") else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}

#Preview {
    Chat(userName: "Preview")
}
