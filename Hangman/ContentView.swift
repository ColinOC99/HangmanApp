import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var game = HangmanGame()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Snowman!")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
                
                // Hangman drawing
                HangmanDrawing(incorrectGuesses: game.incorrectGuesses)
                    .frame(height: 200)
                
                Text("Guesses Remaining: \(6-game.incorrectGuesses)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Word display
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(game.word.enumerated()), id: \.offset) { index, char in
                            Text(game.guessedLetters.contains(String(char)) ? String(char) : "_")
                                .font(.system(size: 28, weight: .bold))
                                .frame(minWidth: 30, minHeight: 45)
                                .padding(.horizontal, 4)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                
                
                // Game status
                if game.isGameOver {
                    VStack(spacing: 5) {
                        Text(game.hasWon ? "🎉 You Won!" : "💀 Game Over!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(game.hasWon ? .green : .red)
                        
                        if !game.hasWon {
                            Text("Word was: \(game.word)")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            game.newGame()
                        }) {
                            Text("New Game")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    Spacer().frame(height: 20)
                }
                
                // Keyboard
                VStack(spacing: 16) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 8) {
                            ForEach(game.keyboardRows[row], id: \.self) { letter in
                                Button(action: {
                                    game.guess(letter: letter)
                                }) {
                                    Text(letter)
                                        .font(.system(size: 20, weight: .semibold))
                                        .frame(width: 32, height: 44)
                                        .background(game.guessedLetters.contains(letter) ? Color.gray.opacity(0.5) : Color.white.opacity(0.9))
                                        .cornerRadius(6)
                                        .foregroundColor(.black)
                                }
                                .disabled(game.guessedLetters.contains(letter) || game.isGameOver)
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
    }
}

class HangmanGame: ObservableObject {
    @Published var word: String = ""
    @Published var guessedLetters: Set<String> = []
    @Published var incorrectGuesses: Int = 0
    
    let maxIncorrectGuesses = 6
    let words = ["SWIFT", "XCODE", "IPHONE", "DEVELOPER", "PROGRAMMING", "APPLICATION", "COMPUTER", "KEYBOARD", "ALGORITHM", "DATABASE"]
    
    let keyboardRows = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["Z", "X", "C", "V", "B", "N", "M"]
    ]
    
    init() {
        newGame()
    }
    
    var displayWord: String {
        word.map { guessedLetters.contains(String($0)) ? String($0) : "_" }.joined(separator: " ")
    }
    
    var isGameOver: Bool {
        hasWon || incorrectGuesses >= maxIncorrectGuesses
    }
    
    var hasWon: Bool {
        word.allSatisfy { guessedLetters.contains(String($0)) }
    }
    
    func guess(letter: String) {
        guard !isGameOver, !guessedLetters.contains(letter) else { return }
        
        guessedLetters.insert(letter)
        
        if !word.contains(letter) {
            incorrectGuesses += 1
        }
    }
    
    func newGame() {
        word = words.randomElement() ?? "SWIFT"
        guessedLetters = []
        incorrectGuesses = 0
    }
}

struct HangmanDrawing: View {
    let incorrectGuesses: Int
    
    var body: some View {
        ZStack {
            // Base
            Rectangle()
                .fill(Color.brown)
                .frame(width: 120, height: 10)
                .offset(y: 95)
            
            // Pole
            Rectangle()
                .fill(Color.brown)
                .frame(width: 10, height: 200)
                .offset(x: -50, y: 0)
            
            // Top beam
            Rectangle()
                .fill(Color.brown)
                .frame(width: 80, height: 10)
                .offset(x: -10, y: -95)
            
            // Rope
            if incorrectGuesses > 0 {
                Rectangle()
                    .fill(Color.brown)
                    .frame(width: 2, height: 30)
                    .offset(x: 30, y: -65)
            }
            
            // Head
            if incorrectGuesses > 1 {
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 30, height: 30)
                    .offset(x: 30, y: -40)
            }
            
            // Body
            if incorrectGuesses > 2 {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 3, height: 40)
                    .offset(x: 30, y: -5)
            }
            
            // Left arm
            if incorrectGuesses > 3 {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 25, height: 3)
                    .rotationEffect(.degrees(-45))
                    .offset(x: 15, y: -15)
            }
            
            // Right arm
            if incorrectGuesses > 4 {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 25, height: 3)
                    .rotationEffect(.degrees(45))
                    .offset(x: 45, y: -15)
            }
            
            // Legs
            if incorrectGuesses > 5 {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 25, height: 3)
                        .rotationEffect(.degrees(-45))
                        .offset(x: 15, y: 18)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 25, height: 3)
                        .rotationEffect(.degrees(45))
                        .offset(x: 45, y: -7)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
