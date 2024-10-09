#include <metal_stdlib>
using namespace metal;

struct VertexOut {
  float4 position [[position]];
  float2 texCoord;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]]) {
  VertexOut out;

  float2 positions[4] = {
    float2(-1.0, -1.0),
    float2( 1.0, -1.0),
    float2(-1.0,  1.0),
    float2( 1.0,  1.0)
  };

  float2 texCoords[4] = {
    float2(0.0, 1.0),
    float2(1.0, 1.0),
    float2(0.0, 0.0),
    float2(1.0, 0.0)
  };

  out.position = float4(positions[vertexID], 0.0, 1.0);
  out.texCoord = texCoords[vertexID];

  return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float> symbolTexture [[texture(0)]],
                               texture2d<float> maskTexture [[texture(1)]],
                               sampler s [[sampler(0)]]) {
  float4 color = symbolTexture.sample(s, in.texCoord);

  // Sample the mask texture
  float maskValue = maskTexture.sample(s, in.texCoord).r;

  // Apply the mask: maskValue == 0 (opaque), maskValue == 1 (transparent)
  color.a *= maskValue;

  return color;
}
