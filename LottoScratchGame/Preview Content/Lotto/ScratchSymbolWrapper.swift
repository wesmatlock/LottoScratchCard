// ScratchSymbolWrapper.swift

import Foundation

class ScratchSymbolWrapper: ObservableObject, Identifiable {
  @Published var symbol: ScratchSymbol

  var id: UUID {
    symbol.id
  }

  init(symbol: ScratchSymbol) {
    self.symbol = symbol
  }
}
