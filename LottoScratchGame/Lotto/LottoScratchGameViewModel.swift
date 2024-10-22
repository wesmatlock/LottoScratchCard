// LottoScratchGameViewModel.swift

import AVFoundation
import Combine
import SwiftUI

@Observable
final class LottoScratchGameViewModel {
  // MARK: - Properties

  var symbols: [ScratchSymbolWrapper] = []
  var revealedSymbols = Set<UUID>()
  var matchedSymbolCount = 0
  var winningSymbolCount = 1

  var hasWon = false
  var showConfetti = false

  let cardSize = CGSize(width: 350, height: 500)
  let symbolSize: CGFloat = 40

  var targetSymbol: String

  // Decide whether to include the target symbol with a 5% chance 0.05
  let includeTargetSymbol = Double.random(in: 0..<1) < 0.95

  private let gridRows = 9
  private let gridColumns = 3

  private var audioPlayer: AVAudioPlayer?
  private var cancellables = Set<AnyCancellable>()

  // MARK: - Initializer

  init() {
    targetSymbol = Constants.possibleSymbols.randomElement() ?? Constants.possibleSymbols[0]
    symbols = generateGridSymbols()
    observeSymbols()
  }

  // MARK: - Reset Game

  func resetGame() {
    // Cancel existing subscriptions
    cancellables.removeAll()

    // Reset properties
    revealedSymbols = Set<UUID>()
    matchedSymbolCount = 0
    hasWon = false
    showConfetti = false

    // Generate new target symbol and symbols grid
    targetSymbol = Constants.possibleSymbols.randomElement() ?? Constants.possibleSymbols[0]
    symbols = generateGridSymbols()

    // Observe the new symbols
    observeSymbols()
  }

  // MARK: - Symbol Generation

  private func generateGridSymbols() -> [ScratchSymbolWrapper] {
    var generatedSymbols = [ScratchSymbol]()
    // Calculate the grid size and positions
    let cellWidth = cardSize.width / CGFloat(gridColumns)
    let cellHeight = cardSize.height / CGFloat(gridRows)

    // If we are including the target symbol, select a random index for its position
    let totalCells = gridRows * gridColumns
    var targetSymbolIndex: Int? = nil
    if includeTargetSymbol {
      targetSymbolIndex = Int.random(in: 0..<totalCells)
    }
    var currentIndex = 0

    for row in 0..<gridRows {
      for column in 0..<gridColumns {
        let symbolName: String

        if let targetIndex = targetSymbolIndex, currentIndex == targetIndex {
          // Insert the target symbol at the selected position
          symbolName = targetSymbol
        } else {
          // Select a random symbol from possible symbols
          symbolName = Constants.possibleSymbols.randomElement() ?? Constants.possibleSymbols[0]
        }

        let position = CGRect(
          x: CGFloat(column) * cellWidth + cellWidth / 2 - symbolSize / 2,
          y: CGFloat(row) * cellHeight + cellHeight / 2 - symbolSize / 2,
          width: symbolSize,
          height: symbolSize
        )

        let symbol = ScratchSymbol(symbolName: symbolName, position: position)
        generatedSymbols.append(symbol)
        currentIndex += 1
      }
    }

    // Shuffle the symbols to randomize positions
    generatedSymbols.shuffle()

    // Wrap in ScratchSymbolWrapper
    return generatedSymbols.map { ScratchSymbolWrapper(symbol: $0) }
  }

  // MARK: - Observing Symbols

  func observeSymbols() {
    for symbolWrapper in symbols {
      symbolWrapper.$symbol.sink { [weak self] _ in
        DispatchQueue.main.async {
          self?.symbolDidChange(symbolWrapper)
        }
      }.store(in: &cancellables)
    }
  }

  private func symbolDidChange(_ symbolWrapper: ScratchSymbolWrapper) {
    if symbolWrapper.symbol.isFullyRevealed && !revealedSymbols.contains(symbolWrapper.id) {
      revealedSymbols.insert(symbolWrapper.id)
      if symbolWrapper.symbol.symbolName == targetSymbol {
        playSound(named: "match")
        matchedSymbolCount += 1
        symbolWrapper.isMatched = true
        triggerHapticFeedback()
      }
      checkWinningCondition()
    }
  }

  // MARK: - Game Logic

  func checkWinningCondition() {
    if revealedSymbols.count == symbols.count && matchedSymbolCount >= winningSymbolCount {
      withAnimation {
        hasWon = true
        showConfetti = true
      }

      triggerWinningHapticFeedback()
      playSound(named: "win")
    }
  }

  // MARK: - Haptic and Sound Feedback

  private func triggerHapticFeedback() {
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    impactFeedback.impactOccurred()
  }

  private func triggerWinningHapticFeedback() {
    let notificationFeedback = UINotificationFeedbackGenerator()
    notificationFeedback.notificationOccurred(.success)
  }

  private func playSound(named soundName: String) {
    guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
    audioPlayer = try? AVAudioPlayer(contentsOf: soundURL)
    audioPlayer?.play()
  }
}

// MARK: - Symbols to use
private enum Constants {
  static let possibleSymbols: [String] = [
    "star.fill", "diamond.fill", "dollarsign.circle.fill", "heart.fill",
    "bolt.fill", "leaf.fill", "sun.max.fill", "moon.fill",
    "flame.fill", "hare.fill", "tortoise.fill", "pawprint.fill",
    "ant.fill", "car.fill", "airplane", "bicycle",
    "bus.fill", "tram.fill", "cloud.fill", "umbrella.fill",
    "goforward", "gobackward", "magnifyingglass", "clock.fill",
    "alarm.fill", "bell.fill", "message.fill", "bubble.left.fill",
    "envelope.fill", "doc.fill", "folder.fill", "scissors",
    "bag.fill", "cart.fill", "creditcard.fill", "bookmark.fill",
    "book.fill", "globe", "house.fill", "building.2.fill",
    "map.fill", "flag.fill", "pencil.tip", "eyeglasses",
    "music.note", "guitars.fill", "figure.walk", "play.circle.fill",
    "stop.circle.fill", "record.circle.fill"
  ]
}
