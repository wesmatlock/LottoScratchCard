// ConfettiView.swift

import SwiftUI

struct ConfettiView: View {
  @State private var confettiParticles: [ConfettiParticle] = []
  var particleCount = 100
  var particleSizeRange: ClosedRange<CGFloat> = 5...10

  var body: some View {
    GeometryReader { geometry in
      ZStack {
//        Color.black // Apply the background color here to fill the entire view.
//          .edgesIgnoringSafeArea(.all) // Make sure the background covers the whole screen.

        ForEach(confettiParticles) { particle in
          particle
        }
      }
      .onAppear {
        generateConfetti(in: geometry.size)
      }
      .onTapGesture {
        // Regenerate confetti on tap.
        generateConfetti(in: geometry.size)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private func generateConfetti(in size: CGSize) {
    confettiParticles = (0..<particleCount).map { index in
      // Generate positions across the entire width and above the screen height.
      let xPosition = CGFloat.random(in: 0...size.width)
      let yPosition = CGFloat.random(in: -size.height...0) // Start above the visible area.

      // Create a confetti particle with a random position.
      return ConfettiParticle(
        id: index,
        color: .random, // Use the Color.random method.
        size: CGFloat.random(in: particleSizeRange),
        initialPosition: CGPoint(x: xPosition - size.width / 2, y: yPosition) // Center it correctly.
      )
    }
  }
}

#Preview {
  ConfettiView()
}
