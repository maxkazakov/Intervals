//
//  SwiftUIView.swift
//  
//
//  Created by Максим Казаков on 04.09.2022.
//

import SwiftUI

enum PauseResumeButtonState {
    case paused
    case playing
}

struct PauseResumeButton: View {
    let state: PauseResumeButtonState
    let onStart: () -> Void
    let onPause: () -> Void

    var body: some View {
        Button(action: {
            switch state {
            case .paused:
                onStart()
            case .playing:
                onPause()
            }
        }, label: {
            content
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black)
                .clipShape(Capsule())
        })
    }

    @ViewBuilder
    var content: some View {
        switch state {
        case .playing:
            Label(title: { Text("pause") }, icon: { Image(systemName: "pause.fill") })
        case .paused:
            Label(title: { Text("continue") }, icon: { Image(systemName: "play.fill") })
        }
    }
}

struct PauseResumeButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PauseResumeButton(state: .paused, onStart: {}, onPause: {})
            PauseResumeButton(state: .playing, onStart: {}, onPause: {})
        }
    }
}
