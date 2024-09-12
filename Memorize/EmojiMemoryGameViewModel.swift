//
//  EmojiMemoryGameViewModel.swift
//  Memorize
//
//  Created by Tony Fernandez on 8/06/24.
//

import SwiftUI

class EmojiMemoryGameViewModel: ObservableObject {
    typealias Card = EmojiMemoryGameModel<String>.Card
    
    // Emojis that are used in the game
    private static let emojis = ["👻","🎃","🕷️","😈","💀","🕸️","🧙‍♀️","🙀","👹","😱",]
    
    // Function that creates a memory game with the given emojis
    private static func createMemoryGame() -> EmojiMemoryGameModel<String> {
        return EmojiMemoryGameModel(numberOfPairsOfCards: emojis.count) { pairIndex in
            return emojis[pairIndex]
        }
    }
    
    @Published private var model = createMemoryGame()
    
    // Initialize ViewModel and shuffle the cards once the game starts
    init() {
        shuffle()
    }
    
    var cards: Array<Card> {
        model.cards
    }
    
    // Color of the card's and deck's foreground
    var color: Color {
        Color(red: 0.5176, green: 0.7255, blue: 0.9294)
    }
    
    var score: Int {
        model.score
    }
    
    var allCardsMatched: Bool {
        model.cards.allSatisfy { $0.isMatched }
    }
    
    
    // MARK: - Intents
    
    func shuffle() {
        model.shuffle()
    }
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func addPoints(_ points: Int) {
        model.addPoints(points)
    }
}
