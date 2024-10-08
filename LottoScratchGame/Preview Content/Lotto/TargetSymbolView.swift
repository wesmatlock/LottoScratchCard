// TargetSymbolView.swift

import SwiftUI

struct TargetSymbolView: View {
  let viewModel: LottoScratchGameViewModel

  var body: some View {
    VStack {
      Text("Match this symbol to win!")
        .font(.headline)
        .padding(.bottom, 5)

      Image(systemName: viewModel.targetSymbol)
        .resizable()
        .frame(width: viewModel.symbolSize, height: viewModel.symbolSize)
        .foregroundStyle(Color.yellow)
        .scaleEffect(viewModel.hasWon ? 1 : 1.5)
        .opacity(viewModel.hasWon ? 1 : 0.7)
        .animation(
          .easeInOut(duration: 1).repeatForever(autoreverses: true),
          value: viewModel.hasWon
        )

      if viewModel.hasWon {
        Text("Congratulations! You matched: \(viewModel.matchedSymbolCount) \(viewModel.targetSymbol) symbols!")
          .font(.headline)
          .foregroundStyle(Color.green)
          .padding()
      } else {
        Text("Matched Symbols: \(viewModel.matchedSymbolCount)")
          .font(.subheadline)
          .foregroundStyle(Color.white)
          .padding()
      }
    }
  }
}

#Preview {
  TargetSymbolView(viewModel: LottoScratchGameViewModel())
}
