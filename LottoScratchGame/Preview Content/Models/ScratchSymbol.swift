// ScratchSymbol.swift

import SwiftUI

struct ScratchSymbol: Identifiable {
  let id = UUID()
  let symbolName: String
  let position: CGRect
  var scratchedCells: Set<Int> = [] // Track scratched cells by index
  let totalCells = 100 // e.g., a 10x10 grid
  var isFullyRevealed = false
}
