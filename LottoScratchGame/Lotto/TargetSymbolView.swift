// TargetSymbolView.swift

import SwiftUI

struct TargetSymbolView: View {
  let viewModel: LottoScratchGameViewModel

  var body: some View {
    VStack {
      Text("Match this symbol to win!")
        .padding(.bottom, 5)

      Image(systemName: viewModel.targetSymbol)
        .resizable()
        .frame(width: viewModel.symbolSize, height: viewModel.symbolSize)
        .foregroundStyle(Color.symbol)
        .scaleEffect(viewModel.hasWon ? 1 : 1.5)
        .opacity(viewModel.hasWon ? 1 : 0.7)
        .animation(
          .easeInOut(duration: 1).repeatForever(autoreverses: true),
          value: viewModel.hasWon
        )

      if viewModel.hasWon {
        HStack {
          Text("Congratulations! You matched: \(viewModel.matchedSymbolCount)")
          Image(systemName: viewModel.targetSymbol)
        }
        .foregroundStyle(Color.green)
        .padding()
      } else {
        Text("Matched Symbols: \(viewModel.matchedSymbolCount)")
          .foregroundStyle(Color.black)
          .padding()
      }
    }
    .font(.headline)
  }
}

#Preview {
  TargetSymbolView(viewModel: LottoScratchGameViewModel())
}
