//
//  SwiftUIView.swift
//  
//
//  Created by Максим Казаков on 04.09.2022.
//

import SwiftUI

struct StartButton: View {
    let onStart: () -> Void

    var body: some View {
        Button(
            action: onStart,
            label: {
                Text("start")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(30)
                    .background(Color.black)
                    .clipShape(Circle())
            }
        )
    }
}

struct StartButtonButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StartButton(onStart: {})
        }
    }
}
