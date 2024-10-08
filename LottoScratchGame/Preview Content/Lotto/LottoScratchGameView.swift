// LottoScratchGameView.swift

import SwiftUI

struct LottoScratchGameView: View {
  private var viewModel = LottoScratchGameViewModel()

  var body: some View {
    VStack {
//      TargetSymbolView(viewModel: viewModel)
      ScratchCardView(viewModel: viewModel)
    }
    .padding()
  }
}

#Preview {
  LottoScratchGameView()
}
