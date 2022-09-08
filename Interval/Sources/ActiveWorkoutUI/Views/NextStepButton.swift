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

    var body: some View {
        Button(
            action: action,
            label: {
                Text(title)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(30)
                    .background(Color.black)
                    .clipShape(Circle())
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
