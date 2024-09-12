//
//  Cardify.swift
//  Memorize
//
//  Created by Tony Fernandez on 8/12/24.
//

import SwiftUI

struct Cardify: ViewModifier, Animatable {
    // Initialize with face-up status
    init(isFaceUp: Bool) {
        rotation = isFaceUp ? 0 : 180
    }
    
    // To check if card is face up
    var isFaceUp: Bool {
        rotation < 90
    }
    
    var rotation: Double
    
    var animatableData: Double {
        get { return rotation}
        set { rotation = newValue}
    }
    
    // Card's appearance based on if face up or not
    func body(content: Content) -> some View {
        ZStack {
            let base = RoundedRectangle(cornerRadius: Constants.cornerRadius)
                base.strokeBorder(lineWidth: Constants.lineWidth)
                    .background(base.fill(.white))
                    .overlay(content)
                    .opacity(isFaceUp ? 1 : 0)
            base.fill()
                .opacity(isFaceUp ? 0 : 1)
        }
        .rotation3DEffect(
            .degrees(rotation), axis: (0,1,0)
        )
    }
    
    // Constants for card's appearance
    private struct Constants {
        static let cornerRadius: CGFloat = 12
        static let lineWidth: CGFloat = 2
    }
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        modifier(Cardify(isFaceUp: isFaceUp))
    }
}
