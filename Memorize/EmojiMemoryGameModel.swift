//
//  EmojiMemoryGameModel.swift
//  Memorize
//
//  Created by Tony Fernandez on 8/06/24.
//

import Foundation

struct EmojiMemoryGameModel<CardContent> where CardContent: Equatable {
    private(set) var cards: Array<Card>         // Array to hold all cards in the game
    private(set) var score = 0                  // Game score
    private(set) var numberOfCards = 10         // Number of cards in the game
    
    // Initialize the game with a given number of pairs of cards and the content for each pair
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = []
        // add numberOfPairsOfCards x 2 cards
        for pairIndex in 0..<max(2,numberOfPairsOfCards) {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: "\(pairIndex+1)a"))
            cards.append(Card(content: content, id: "\(pairIndex+1)b"))
        }
    }
    
    // Keeping track of the indeces
    var indexOfFaceUpCard: Int? {
        get { cards.indices.filter { index in cards[index].isFaceUp }.only }
        set { cards.indices.forEach { cards[$0].isFaceUp = (newValue == $0) } }
    }
    
    // Function to choose a card and handle game logic
    mutating func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: {$0.id == card.id}) {
            if !cards[chosenIndex].isFaceUp && !cards[chosenIndex].isMatched {
                if let potentialMatchIndex = indexOfFaceUpCard {
                    if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                        cards[chosenIndex].isMatched = true
                        cards[potentialMatchIndex].isMatched = true
                        score += 2
                    } else {
                        if cards[chosenIndex].hasBeenSeen && score > 0 {
                            score -= 1
                        }
                        if cards[potentialMatchIndex].hasBeenSeen && score > 0 {
                            score -= 1
                        }
                    }
                } else {
                    indexOfFaceUpCard = chosenIndex
                }
                cards[chosenIndex].isFaceUp = true
            }
        }
    }
    
    // Function to shuffle the cards randomly
    mutating func shuffle() {
        cards.shuffle()
    }
    
    // Function to add points
    mutating func addPoints(_ points: Int) {
        score += points
    }
    
    // Card struct representing each card in the memory game
    struct Card: Equatable, Identifiable, CustomDebugStringConvertible {
        var isFaceUp = false {
            didSet {
                if oldValue && !isFaceUp {
                    hasBeenSeen = true
                }
            }
        }
        var hasBeenSeen = false
        var isMatched = false
        let content: CardContent
        
        var id: String
        var debugDescription: String {
            "\(id): \(content) \(isFaceUp ? "up" : "down") \(isMatched ? " matched" : "")"
        }
    }
}

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
