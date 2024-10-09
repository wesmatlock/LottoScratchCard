import SwiftUI

struct SymbolView: View {
  @ObservedObject var symbol: ScratchSymbolWrapper
  let animationNamespace: Namespace.ID

  var body: some View {
    ZStack {
      if symbol.symbol.isFullyRevealed {
        // Display the symbol image when fully revealed
        Image(systemName: symbol.symbol.symbolName)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: symbol.symbol.position.width, height: symbol.symbol.position.height)
          .position(x: symbol.symbol.position.midX, y: symbol.symbol.position.midY)
          .foregroundStyle(Color.white)
          .matchedGeometryEffect(id: symbol.symbol.id, in: animationNamespace)
          .accessibilityElement()
          .accessibilityLabel(Text(symbol.symbol.symbolName))
          .accessibilityHidden(!symbol.symbol.isFullyRevealed)
      } else {
        // Use MetalViewRepresentable for the scratchable symbol
        MetalViewRepresentable(
          symbolName: symbol.symbol.symbolName,
          isFullyRevealed: $symbol.symbol.isFullyRevealed
        )
        .frame(width: symbol.symbol.position.width, height: symbol.symbol.position.height)
        .position(x: symbol.symbol.position.midX, y: symbol.symbol.position.midY)
      }
    }
  }
}
