// ConfettiView.swift

import SwiftUI

struct ConfettiView: View {
  @State private var confettiParticles: [ConfettiParticle] = []

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        ForEach(confettiParticles) { particle in
          particle
        }
      }
      .onAppear {
        generateConfetti(in: geometry.size)
      }
    }
  }

  private func generateConfetti(in size: CGSize) {
    let colors: [Color] = [.red, .blue, .yellow, .orange, .green, .purple]

    for _ in 0..<100 {
      let xPosition = CGFloat.random(in: 0...size.width)
      let yPosition = CGFloat.random(in: -size.height...0)
      let particle = ConfettiParticle(
        color: colors.randomElement() ?? .white,
        size: CGFloat.random(in: 5...10),
        position: CGPoint(x: xPosition, y: yPosition)
      )
      confettiParticles.append(particle)
    }
  }
}

 #Preview {
    ConfettiView()
 }
