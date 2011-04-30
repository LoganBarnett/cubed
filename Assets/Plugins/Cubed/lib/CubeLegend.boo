namespace Cubed

import UnityEngine
import System.Collections.Generic

class CubeLegend:
  [Property(CubeDefinitions)]
  cubeDefinitions as (CubeDefinition)

  [Property(TextureAtlas)]
  textureAtlas as (Rect)

  def UvsFor(type as int, side as Direction):
    coords = textureAtlas[cast(int, side) + (type * 6)]
    #topLeft     = Vector2(coords.y, coords.x)
    #topRight    = Vector2(coords.y, coords.x + coords.width)
    #bottomLeft  = Vector2(coords.y + coords.height, coords.x)
    #bottomRight = Vector2(coords.y + coords.height, coords.x + coords.width)
    topLeft     = Vector2(coords.x, coords.y)
    topRight    = Vector2(coords.x, coords.y + coords.height)
    bottomLeft  = Vector2(coords.x + coords.width, coords.y)
    bottomRight = Vector2(coords.x + coords.width, coords.y + coords.height)
    return (topLeft, topRight, bottomLeft, bottomRight)
    
  def AllUvs(type as int):
    uvs = List of Vector2()
    for i in range(0, 5):
      uvs.AddRange(UvsFor(type, i))
    return uvs.ToArray()