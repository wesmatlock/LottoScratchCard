// LottoScratchGameView.swift

import SwiftUI

struct LottoScratchGameView: View {
  private var viewModel = LottoScratchGameViewModel()

  var body: some View {
    VStack {
      Spacer()
      TargetSymbolView(viewModel: viewModel)
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
      ScratchCardView(viewModel: viewModel)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(0.6, contentMode: .fit)
      Spacer()
    }
    .background(Color.red.opacity(0.2))
//    .edgesIgnoringSafeArea(.bottom)
  }
}

#Preview {
  LottoScratchGameView()
}
