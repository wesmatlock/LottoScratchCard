import SwiftUI
import MetalKit

struct MetalViewRepresentable: UIViewRepresentable {
  let symbolName: String
  @Binding var isFullyRevealed: Bool

  func makeUIView(context: Context) -> MetalView {
    let metalView = MetalView(symbolName: symbolName)
    metalView.delegate = context.coordinator
    metalView.isFullyRevealedBinding = $isFullyRevealed

    // Add touch handling
    let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
    metalView.addGestureRecognizer(panGesture)

    return metalView
  }

  func updateUIView(_ uiView: MetalView, context: Context) {
    // Update binding
    uiView.isFullyRevealedBinding = $isFullyRevealed
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, MTKViewDelegate {
    var parent: MetalViewRepresentable

    init(_ parent: MetalViewRepresentable) {
      self.parent = parent
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
      let metalView = gesture.view as! MetalView
      let location = gesture.location(in: metalView)
      metalView.addTouchPoint(location)
    }

    // Required MTKViewDelegate methods (can be empty if not used)
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
      // Handle size changes if necessary
    }

    func draw(in view: MTKView) {
      // Drawing is handled in MetalView
    }
  }
}
