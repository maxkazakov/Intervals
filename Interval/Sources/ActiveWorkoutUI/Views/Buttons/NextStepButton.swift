//
//  NextStepButton.swift
//  
//
//  Created by Максим Казаков on 09.09.2022.
//

import SwiftUI

struct NextStepButton: View {
    let title: String
    let action: () -> Void
    @GestureState var tap = false

    var body: some View {
        Button(
            action: { action() },
            label: {
                Image(systemName: "forward.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
        )
    }
}

struct NextStepButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NextStepButton(title: "next step", action: {})
        }
    }
}
