// ScratchableOverlay.swift

import SwiftUI

struct ScratchableOverlay: View {
  @ObservedObject var symbol: ScratchSymbolWrapper
  let gridSize: Int

  var body: some View {
    GeometryReader { geometry in
      let cellWidth = geometry.size.width / CGFloat(gridSize)
      let cellHeight = geometry.size.height / CGFloat(gridSize)

      ZStack {
        ForEach(0..<gridSize * gridSize, id: \.self) { index in
          let row = index / gridSize
          let column = index % gridSize

          Rectangle()
            .fill(Color.gray)
            .frame(width: cellWidth, height: cellHeight)
            .position(x: (CGFloat(column) + 0.5) * cellWidth, y: (CGFloat(row) + 0.5) * cellHeight)
            .opacity(symbol.symbol.scratchedCells.contains(index) ? 0 : 1)
        }
      }
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { value in
            // Determine which cell is being scratched
            let x = Int(value.location.x / cellWidth)
            let y = Int(value.location.y / cellHeight)
            let index = y * gridSize + x
            if x >= 0 && x < gridSize && y >= 0 && y < gridSize {
              if !symbol.symbol.scratchedCells.contains(index) {
                symbol.symbol.scratchedCells.insert(index)
                checkIfFullyRevealed()
              }
            }
          }
      )
    }
    .compositingGroup() // Ensures correct rendering of opacity
  }

  private func checkIfFullyRevealed() {
    let scratchedPercentage = (Double(symbol.symbol.scratchedCells.count) / Double(symbol.symbol.totalCells)) * 100
    if scratchedPercentage >= 90 {
      symbol.symbol.isFullyRevealed = true
    }
  }
}
