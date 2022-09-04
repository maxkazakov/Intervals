//
//  StopButton.swift
//  
//
//  Created by Максим Казаков on 04.09.2022.
//

import SwiftUI

struct StopButton: View {
    let onStop: () -> Void

    var body: some View {
        Button(
            action: onStop,
            label: {
                Label(title: { Text("stop") }, icon: { Image(systemName: "stop.fill") })
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
        )
    }
}

struct StopButtonButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StopButton(onStop: {})
        }
    }
}
