import MetalKit
import SwiftUI

class MetalView: MTKView {
  // MARK: - Properties

  var commandQueue: MTLCommandQueue!
  var pipelineState: MTLRenderPipelineState!
  var symbolTexture: MTLTexture!
  var maskTexture: MTLTexture!
  var touchPoints: [CGPoint] = []
  var isFullyRevealedBinding: Binding<Bool>?

  var samplerState: MTLSamplerState!

  private var symbolName: String

  // MARK: - Initialization

  init(symbolName: String) {
    self.symbolName = symbolName
    super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
    commonInit()
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func commonInit() {
    self.device = MTLCreateSystemDefaultDevice()
    self.commandQueue = device?.makeCommandQueue()
    self.framebufferOnly = false
    self.isPaused = true // Control rendering manually
    self.enableSetNeedsDisplay = true
    self.contentScaleFactor = UIScreen.main.scale

    setupPipeline()
  }

  private func setupSampler() {
    let samplerDescriptor = MTLSamplerDescriptor()
    samplerDescriptor.minFilter = .linear
    samplerDescriptor.magFilter = .linear
    samplerDescriptor.mipFilter = .notMipmapped
    samplerDescriptor.sAddressMode = .clampToEdge
    samplerDescriptor.tAddressMode = .clampToEdge

    samplerState = device?.makeSamplerState(descriptor: samplerDescriptor)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    print("drawableSize: \(self.drawableSize)")


    if symbolTexture == nil || maskTexture == nil {
      loadTextures()
    }
  }
  // MARK: - Setup Methods

  private func setupPipeline() {
    guard let device = self.device else { return }

    // Create a library with the Metal shader functions
    let defaultLibrary = device.makeDefaultLibrary()

    // Create a pipeline state
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader")
    pipelineDescriptor.fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentShader")
    pipelineDescriptor.colorAttachments[0].pixelFormat = self.colorPixelFormat

    do {
      pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch let error {
      print("Failed to create pipeline state, error \(error)")
    }

    setupSampler()

  }

  private func loadTextures() {
    guard let device = self.device else { return }

    // Ensure drawableSize is valid
    let textureWidth = max(1, Int(self.drawableSize.width * self.contentScaleFactor))
    let textureHeight = max(1, Int(self.drawableSize.height * self.contentScaleFactor))

    // Load the symbol image as a texture
    let textureLoader = MTKTextureLoader(device: device)
    if let image = UIImage(systemName: symbolName)?.withTintColor(.white, renderingMode: .alwaysOriginal) {
      // Render UIImage into CGImage
      let size = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
      UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
      image.draw(in: CGRect(origin: .zero, size: size))
      let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      if let cgImage = renderedImage?.cgImage {
        do {
          let options: [MTKTextureLoader.Option: Any] = [
            .SRGB: false,
            .origin: MTKTextureLoader.Origin.bottomLeft
          ]
          symbolTexture = try textureLoader.newTexture(cgImage: cgImage, options: options)
        } catch {
          print("Failed to load texture: \(error)")
        }
      } else {
        print("Failed to get CGImage from rendered UIImage for symbol: \(symbolName)")
      }
    } else {
      print("Failed to create UIImage for symbol: \(symbolName)")
    }

    // Proceed only if symbolTexture is successfully loaded
    guard symbolTexture != nil else {
      print("Symbol texture is nil. Aborting texture loading.")
      return
    }

    // Create an empty mask texture
    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: .r8Unorm,
      width: textureWidth,
      height: textureHeight,
      mipmapped: false)
    textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
    maskTexture = device.makeTexture(descriptor: textureDescriptor)

    // Check if maskTexture was created successfully
    guard let maskTexture = maskTexture else {
      print("Failed to create mask texture.")
      return
    }

    // Fill the mask texture with 0 (opaque)
    let region = MTLRegionMake2D(0, 0, textureWidth, textureHeight)
    var initialData = [UInt8](repeating: 0, count: textureWidth * textureHeight)
    maskTexture.replace(region: region, mipmapLevel: 0, withBytes: &initialData, bytesPerRow: textureWidth)
  }

  // MARK: - Rendering

  override func draw(_ rect: CGRect) {
    guard
      let drawable = currentDrawable,
      let commandBuffer = commandQueue.makeCommandBuffer(),
      let renderPassDescriptor = currentRenderPassDescriptor,
      let pipelineState = pipelineState
    else { return }

    // Update the mask texture based on touch points
    updateMaskTexture()

    // Set up render command encoder
    let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    encoder.setRenderPipelineState(pipelineState)

    // Set textures
    encoder.setFragmentTexture(symbolTexture, index: 0)
    encoder.setFragmentTexture(maskTexture, index: 1)

    // Set sampler state
    encoder.setFragmentSamplerState(samplerState, index: 0)

    // Draw a full-screen quad
    encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    encoder.endEncoding()

    // Present the drawable
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }

  // MARK: - Mask Updating

  private func updateMaskTexture() {
    guard !touchPoints.isEmpty, let device = device else { return }

    let commandBuffer = commandQueue.makeCommandBuffer()!
    let blitEncoder = commandBuffer.makeBlitCommandEncoder()!

    for point in touchPoints {
      let radius: CGFloat = 30 * UIScreen.main.scale // Adjust as needed
      let x = Int((point.x - radius).clamped(to: 0...self.drawableSize.width))
      let y = Int((point.y - radius).clamped(to: 0...self.drawableSize.height))
      let width = Int(radius * 2)
      let height = Int(radius * 2)

      // Ensure we don't exceed texture bounds
      let adjustedWidth = min(width, Int(self.drawableSize.width) - x)
      let adjustedHeight = min(height, Int(self.drawableSize.height) - y)

      if adjustedWidth > 0 && adjustedHeight > 0 {
        let region = MTLRegionMake2D(x, y, adjustedWidth, adjustedHeight)
        let dataSize = adjustedWidth * adjustedHeight
        var data = [UInt8](repeating: 255, count: dataSize)

        // Write data to the mask texture
        maskTexture.replace(region: region, mipmapLevel: 0, withBytes: &data, bytesPerRow: adjustedWidth)
      }
    }

    blitEncoder.endEncoding()
    commandBuffer.commit()

    // After updating the mask, check if fully revealed
    checkIfFullyRevealed()

    // Clear touch points
    touchPoints.removeAll()
  }

  private func checkIfFullyRevealed() {
    // Read back the mask texture to determine how much has been revealed
    guard let device = device else { return }

    let textureWidth = Int(self.drawableSize.width)
    let textureHeight = Int(self.drawableSize.height)
    let region = MTLRegionMake2D(0, 0, textureWidth, textureHeight)
    var maskData = [UInt8](repeating: 0, count: textureWidth * textureHeight)
    maskTexture.getBytes(&maskData, bytesPerRow: textureWidth, from: region, mipmapLevel: 0)

    // Calculate the percentage of revealed pixels
    let totalPixels = maskData.count
    let revealedPixels = maskData.filter { $0 == 255 }.count
    let revealedPercentage = (Double(revealedPixels) / Double(totalPixels)) * 100.0

    if revealedPercentage >= 90 {
      DispatchQueue.main.async {
        self.isFullyRevealedBinding?.wrappedValue = true
      }
    }
  }

  // MARK: - Touch Handling

  func addTouchPoint(_ point: CGPoint) {
    touchPoints.append(point)
    self.setNeedsDisplay()
  }
}

// Helper extension to clamp values within a range
extension Comparable {
  func clamped(to limits: ClosedRange<Self>) -> Self {
    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}
