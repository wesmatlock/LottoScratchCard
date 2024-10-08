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
  var winningSymbolCount = 3

  var hasWon = false
  var showConfetti = false

  let cardSize = CGSize(width: 350, height: 600)
  let symbolSize: CGFloat = 40

  var targetSymbol: String

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

  // MARK: - Symbol Generation

  private func generateGridSymbols() -> [ScratchSymbolWrapper] {
    var generatedSymbols = [ScratchSymbol]()
    var targetSymbolCount = 0
    let totalSymbols = gridRows * gridColumns

    // Calculate the grid size and positions
    let cellWidth = cardSize.width / CGFloat(gridColumns)
    let cellHeight = cardSize.height / CGFloat(gridRows)

    for row in 0..<gridRows {
      for column in 0..<gridColumns {
        let symbolName: String

//        if targetSymbolCount < winningSymbolCount {
//          symbolName = targetSymbol
//          targetSymbolCount += 1
//        } else {
          symbolName = Constants.possibleSymbols.randomElement() ?? Constants.possibleSymbols[0]
//        }

        let position = CGRect(
          x: CGFloat(column) * cellWidth + cellWidth / 2 - symbolSize / 2,
          y: CGFloat(row) * cellHeight + cellHeight / 2 - symbolSize / 2,
          width: symbolSize,
          height: symbolSize
        )

        let symbol = ScratchSymbol(symbolName: symbolName, position: position)
        generatedSymbols.append(symbol)
      }
    }

    // Shuffle the symbols to randomize positions
    generatedSymbols.shuffle()

    // Wrap in ScratchSymbolWrapper
    return generatedSymbols.map { ScratchSymbolWrapper(symbol: $0) }
  }

  // MARK: - Observing Symbols

  // Observe symbols and handle changes as before
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
        matchedSymbolCount += 1
        triggerHapticFeedback()
        playSound(named: "scratch")
        checkWinningCondition()
      }
    }
  }

  // MARK: - Game Logic

  func checkWinningCondition() {
    if matchedSymbolCount >= winningSymbolCount {
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
