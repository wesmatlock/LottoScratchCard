// ScratchCardView.swift

import SwiftUI

struct ScratchCardView: View {
  var viewModel: LottoScratchGameViewModel
  @Namespace private var animationNamespace

  var body: some View {
    ZStack {
      symbolsBackgroundView()

      if viewModel.showConfetti {
        ConfettiView()
          .transition(.opacity)
          .animation(.easeOut(duration: 1), value: viewModel.showConfetti)
      }
    }
    .padding()
  }

  // MARK: - Symbols Background View

  @ViewBuilder
  private func symbolsBackgroundView() -> some View {
    RoundedRectangle(cornerRadius: 20)
      .fill(Color.blue)
      .frame(width: viewModel.cardSize.width, height: viewModel.cardSize.height)
      .overlay {
        ForEach(viewModel.symbols) { symbolWrapper in
          SymbolView(
            symbol: symbolWrapper,
            animationNamespace: animationNamespace
          )
        }
      }
  }
}

#Preview {
  ScratchCardView(viewModel: LottoScratchGameViewModel())
}
