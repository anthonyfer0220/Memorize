//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by Tony Fernandez on 8/05/24.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    typealias Card = EmojiMemoryGameModel<String>.Card
    @ObservedObject var viewModel: EmojiMemoryGameViewModel
    
    // Variables that manage game progress and state
    @State private var isGameStarted = false                    // Track if game has started
    @State private var isGameEnded = false                      // Track if game has ended
    @State private var selectedDifficulty: Difficulty? = nil    // Track the chosen difficulty
    @State private var remainingTime = 0                        // Time remaining based on difficulty
    @State private var hasAwardedBonusPoints = false            // Track if bonus points have been awarded
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            difficultyPicker    // Difficulty selection
                .padding()
                .opacity(selectedDifficulty == nil ? 1 : 0)
                .animation(.easeInOut, value: selectedDifficulty)
            HStack {
                score   // Display the current score
                Spacer()
                // Display remaining time
                Text("Time: \(formatTime(remainingTime))")
                    .onReceive(timer) { _ in
                        // Countdown logic and game progress management
                        if isGameStarted && remainingTime > 0 && !viewModel.allCardsMatched {
                            remainingTime -= 1
                        } else if viewModel.allCardsMatched && isGameStarted && !hasAwardedBonusPoints {
                            awardBonusPoints()
                            hasAwardedBonusPoints = true
                            stopTimer()
                            isGameEnded = true
                        } else if remainingTime == 0 && isGameStarted {
                            stopTimer()
                            isGameEnded = true
                        }
                    }
            }
            cards.foregroundColor(viewModel.color)      // Display cards with assigned color from ViewModel
            deck.foregroundColor(viewModel.color)
                .disabled(selectedDifficulty == nil)    // Disable deck interaction until difficulty is chosen
        }
        .font(.largeTitle)
        .padding()
        .onDisappear {
            stopTimer()   // Stop timer when the view disappears
        }
        // Alerts for when the game has ended
        .alert(isPresented: $isGameEnded) {
            if viewModel.allCardsMatched {      // If the player wins
                return Alert(
                    title: Text("Congratulations!"),
                    message: Text("You finished the game with \(remainingTime) seconds left!."),
                    dismissButton: .default(Text("Ok"))
                    )
            } else {                            // If the player loses
                return Alert(
                    title: Text("Time's Up!"),
                    message: Text("You ran out of time."),
                    dismissButton: .default(Text("Ok"))
                    )
            }
        }
    }
    
    // Function to stop timer
    private func stopTimer() {
        timer.upstream.connect().cancel()
    }
    
    // Display current score
    private var score: some View {
        Text("Score: \(viewModel.score)")
            .animation(nil)
    }
    
    // Function to award bonus points depending on difficulty and remainting time
    private func awardBonusPoints() {
        var points: Int = 0
        
        switch selectedDifficulty {
        case .easy:
            points = 2
        case .medium:
            points = 10
        case .hard:
            points = 20
        default:
            points = 0        }
        
        let bonusPoints = remainingTime * points
        viewModel.addPoints(bonusPoints)
    }
    
    // Function that formats time in MM:SS
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Display the cards in a grid layout
    private var cards: some View {
        AspectVGrid(viewModel.cards, aspectRatio: Constants.aspectRatio) { card in
            // Check if card has been dealt
            if isDealt(card) {
                view(for: card)
                    .padding(Constants.spacing)
                    .overlay(FlyingNumber(number: scoreChange(causedBy: card)))
                    .zIndex(scoreChange(causedBy: card) != 0 ? 100 : 0)
                    .onTapGesture {
                        choose(card)    // Choose a card when tapped
                    }
            }
        }
    }
    
    // Difficulty picker to allow user to choose difficulty before game starts
    private var difficultyPicker: some View {
        Picker("Select Difficulty", selection: $selectedDifficulty) {
            Text("Easy (1 min)").tag(Difficulty.easy as Difficulty?)
            Text("Medium (45 sec)").tag(Difficulty.medium as Difficulty?)
            Text("Hard (30 sec)").tag(Difficulty.hard as Difficulty?)
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: selectedDifficulty) { difficulty in
            if let difficulty = difficulty {
                startGame(with: difficulty)     // Start game once difficulty has been chosen
            }
        }
    }
    
    // Card view
    private func view(for card: Card) -> some View {
        CardView(card)
            .matchedGeometryEffect(id: card.id, in: dealingNamespace)
        
    }
    
    // Choose a specific card and update score
    private func choose(_ card: Card) {
        withAnimation {
            let scoreBeforeChoosing = viewModel.score
            viewModel.choose(card)
            let scoreChange = viewModel.score - scoreBeforeChoosing
            lastScoreChange = (scoreChange, causedByCardId: card.id)
        }
    }
    
    @State private var lastScoreChange = (0, causedByCardId: "")    // Track score changes
    
    // Return score change caused by the card
    private func scoreChange(causedBy card: Card) -> Int {
        let (amount, id) = lastScoreChange
        return card.id == id ? amount : 0
    }
    
    // MARK: - Dealing from a Deck
    
    @Namespace private var dealingNamespace
    @State private var dealt = Set<Card.ID>()
    
    // Check if a card has been dealt
    private func isDealt(_ card: Card) -> Bool {
        dealt.contains(card.id)
    }
    
    // Filter out undealt cards
    private var undealtCards: [Card] {
        viewModel.cards.filter { !isDealt($0) }
    }
    
    // Deck of cards with tap gesture for dealing
    private var deck: some View {
        ZStack {
            ForEach(undealtCards) { card in
                view(for: card)
            }
        }
        .frame(width: Constants.deckWidth, height: Constants.deckWidth / Constants.aspectRatio)
        .onTapGesture {
            deal()
        }
        .disabled(isGameStarted || selectedDifficulty == nil) // Disable until difficulty is chosen and game starts
    }
    
    // Function that deals cards with an animation
    private func deal() {
        var delay: TimeInterval = 0
        for card in viewModel.cards {
            withAnimation(Constants.dealAnimation.delay(delay)) {
                _ = dealt.insert(card.id)
            }
            delay += Constants.dealInterval
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            isGameStarted = true
        }
    }
    
    // Function that starts game with the remaining time set by the difficulty chosen
    private func startGame(with difficulty: Difficulty) {
        switch difficulty {
        case .easy:
            remainingTime = 60  // 1 minute for easy
        case .medium:
            remainingTime = 45  // 45 seconds for medium
        case .hard:
            remainingTime = 30  // 30 seconds for hard
        }
        isGameStarted = false     // Game starts once all cards have been dealt
    }
    
    // Constants used for layout and animations
    private struct Constants {
        static let aspectRatio: CGFloat = 2/3
        static let spacing: CGFloat = 4
        static let deckWidth: CGFloat = 50
        static let dealAnimation: Animation = .easeIn(duration: 1.5)
        static let dealInterval: TimeInterval = 0.10
        
    }
}

// Emum for difficulty levels
enum Difficulty {
    case easy
    case medium
    case hard
}

#Preview {
    EmojiMemoryGameView(viewModel: EmojiMemoryGameViewModel())
}
