//
//  CardView.swift
//  Memorize
//
//  Created by Tony Fernandez on 8/12/24.
//

import SwiftUI

struct CardView: View {
    typealias Card = EmojiMemoryGameModel<String>.Card
    
    let card: Card
    
    // Initialize card from the Model
    init(_ card: Card) {
        self.card = card
    }
    
    var body: some View {
        // Only show contents of the card if it's face up and not matched
        if card.isFaceUp || !card.isMatched {
            cardContents
                .padding(Constants.inset)
                .cardify(isFaceUp: card.isFaceUp)
                .transition(.blurReplace)
        } else {
            Color.clear
        }
    }
    
    // Contents of the card
    var cardContents: some View {
        Text(card.content)
            .font(.system(size: Constants.FontSize.largest))
            .minimumScaleFactor(Constants.FontSize.scaleFactor)
            .scaledToFit()
            .rotationEffect(.degrees(card.isMatched ? 360 : 0))
            .animation(.spin(), value: card.isMatched)
    }
    
    // Constants for padding, font size, and scaling
    private struct Constants {
        static let inset: CGFloat = 5
        struct FontSize {
            static let largest: CGFloat = 200
            static let smallest: CGFloat = 10
            static let scaleFactor = smallest / largest
        }
    }
}

extension Animation {
    static func spin() -> Animation {
        .linear(duration: 1.5).repeatForever(autoreverses: false)
    }
}

#Preview {
    // Testing four cards with different properties
    VStack {
        HStack {
            CardView(EmojiMemoryGameModel<String>.Card(isFaceUp: true, content: "X", id: "test1"))
                .aspectRatio(4/3,contentMode: .fit)
            CardView(EmojiMemoryGameModel<String>.Card(content: "X", id: "test1"))
        }
        HStack {
            CardView(EmojiMemoryGameModel<String>.Card(isMatched: false, content: "X", id: "test1"))
            CardView(EmojiMemoryGameModel<String>.Card(content: "X", id: "test1"))
        }
    }
        .padding()
        .foregroundColor(.blue)
}
