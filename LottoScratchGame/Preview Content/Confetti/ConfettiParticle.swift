// ConfettiParticle.swift

import SwiftUI

struct ConfettiParticle: View, Identifiable {
  let id: Int
  var color: Color
  var size: CGFloat
  let initialPosition: CGPoint

  // State for animation of position changes.
  @State private var offsetY: CGFloat = 0

  var body: some View {
    Circle()
      .fill(color)
      .frame(width: size, height: size)
      .offset(x: initialPosition.x, y: initialPosition.y + offsetY)
      .onAppear {
        // Animate the falling movement.
        withAnimation(
          .linear(duration: Double.random(in: 2...4))
          .repeatForever(autoreverses: false)
        ) {
          offsetY = 1000 // Move the particle downward.
        }
      }
  }
}

#Preview {
  GeometryReader { geometry in
    ZStack {
      ForEach(0..<50) { index in
        ConfettiParticle(
          id: index,
          color: Color.random,
          size: CGFloat.random(in: 5...12),
          initialPosition: CGPoint(
            x: CGFloat.random(in: 0...geometry.size.width),
            y: CGFloat.random(in: 0...geometry.size.height)
          )
        )
        // Initially position at the randomized location.
        .offset(
          x: CGFloat.random(in: -geometry.size.width / 2...geometry.size.width / 2),
          y: CGFloat.random(in: -geometry.size.height / 2...geometry.size.height / 2)
        )
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black) // Background to visualize confetti particles better.
  }
}

extension Color {
  static var random: Color {
    Color(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1)
    )
  }
}
