// ConfettiParticle.swift

import SwiftUI

struct ConfettiParticle: View, Identifiable {
  var id: UUID = .init()
  var color: Color
  var size: CGFloat
  let position: CGPoint

  var body: some View {
    Circle()
      .fill(color)
      .frame(width: size, height: size)
      .position(position)
  }
}

#Preview {
  ConfettiParticle(color: .red, size: 10.0, position: CGPoint(x: 150, y: 50))
}
