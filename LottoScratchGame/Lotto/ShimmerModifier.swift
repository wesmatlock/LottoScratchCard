import SwiftUI

struct ShimmerModifier: ViewModifier {
  var repeatCount: Int? = nil
  var duration: Double

  @Binding var shine: Bool
  @Binding var stopShine: Bool

  func body(content: Content) -> some View {
    content
      .overlay(
        LinearGradient(colors: [.clear, .white.opacity(0.8), .clear], startPoint: .leading, endPoint: .trailing)
          .frame(width: 100)
          .offset(x: shine ? -250 : 250)
          .rotationEffect(.degrees(-45))
          .scaleEffect(2)
          .animation(stopShine ?
            .none :
                      repeatCount != nil ?
            .linear(duration: duration).repeatCount(repeatCount!, autoreverses: false) :
              .linear(duration: duration).repeatForever(autoreverses: false), value: stopShine ? false : shine
          )
      )
  }
}

extension View {
  func shimmer(repeatCount: Int? = nil, duration: Double = 3.0, shine: Binding<Bool>, stopShine: Binding<Bool>) -> some View {
    self.modifier(ShimmerModifier(repeatCount: repeatCount, duration: duration, shine: shine, stopShine: stopShine))
  }
}
