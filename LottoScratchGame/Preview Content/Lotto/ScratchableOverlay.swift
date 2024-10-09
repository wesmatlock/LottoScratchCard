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
            // Determine which cells are being scratched
            let x = Int(value.location.x / cellWidth)
            let y = Int(value.location.y / cellHeight)
            if x >= 0 && x < gridSize && y >= 0 && y < gridSize {
              scratchCellsAt(x: x, y: y)
            }
          }
      )
    }
    .compositingGroup() // Ensures correct rendering of opacity
  }

  private func scratchCellsAt(x: Int, y: Int) {
    let gridSize = gridSize
    let radius = 1 // Adjust radius as needed

    let minX = max(0, x - radius)
    let maxX = min(gridSize - 1, x + radius)
    let minY = max(0, y - radius)
    let maxY = min(gridSize - 1, y + radius)

    guard minX <= maxX, minY <= maxY else {
      return // Invalid range, do nothing
    }

    for newX in minX...maxX {
      for newY in minY...maxY {
        let index = newY * gridSize + newX
        if !symbol.symbol.scratchedCells.contains(index) {
          symbol.symbol.scratchedCells.insert(index)
        }
      }
    }
    checkIfFullyRevealed()
  }

  private func checkIfFullyRevealed() {
    let scratchedPercentage = (Double(symbol.symbol.scratchedCells.count) / Double(symbol.symbol.totalCells)) * 100
    if scratchedPercentage >= 90 {
      symbol.symbol.isFullyRevealed = true
    }
  }
}
