//
//  SwiftUIView.swift
//  
//
//  Created by Максим Казаков on 04.09.2022.
//

import SwiftUI

enum StartStopButtonState {
    case paused
    case stopped
    case playing
}

struct StartStopButton: View {
    let state: StartStopButtonState
    let onStart: () -> Void
    let onPause: () -> Void

    var body: some View {
        Button(action: {
            switch state {
            case .paused:
                onStart()
            case .stopped:
                onStart()
            case .playing:
                onPause()
            }
        }, label: {
            content
                .font(.title2)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(Color.black)
                .clipShape(Capsule())
        })
    }

    @ViewBuilder
    var content: some View {
        switch state {
        case .stopped:
            Label(title: { Text("Start") }, icon: { Image(systemName: "play.fill") })
        case .playing:
            Label(title: { Text("Pause") }, icon: { Image(systemName: "stop.fill") })
        case .paused:
            Label(title: { Text("Continue") }, icon: { Image(systemName: "play.fill") })
        }

    }
}

struct StartStopButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StartStopButton(state: .paused, onStart: {}, onPause: {})

            StartStopButton(state: .playing, onStart: {}, onPause: {})

            StartStopButton(state: .stopped, onStart: {}, onPause: {})
        }
    }
}
