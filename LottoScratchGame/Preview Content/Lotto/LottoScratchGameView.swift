// LottoScratchGameView.swift

import SwiftUI

struct LottoScratchGameView: View {
  private var viewModel = LottoScratchGameViewModel()

  var body: some View {
    VStack {
      Spacer()
//      TargetSymbolView(viewModel: viewModel)
//        .frame(maxWidth: .infinity, alignment: .center)
      ScratchCardView(viewModel: viewModel)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .aspectRatio(1, contentMode: .fit)
//        .padding()
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    .background(Color.red.opacity(0.2))
  }
}

#Preview {
  LottoScratchGameView()
}
