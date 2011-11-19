using UnityEngine;
using System.Collections.Generic;

[System.Serializable]
public class CubeLegend {
  public List<CubeDefinition> cubeDefinitions; 
  public List<Rect> textureAtlas;
  
  public List<Vector2> UvsFor(int type, Direction side) {
    var coords = textureAtlas[(int)side + (type * 6)];
    var topLeft     = new Vector2(coords.x, coords.y);
    var topRight    = new Vector2(coords.x, coords.y + coords.height);
    var bottomLeft  = new Vector2(coords.x + coords.width, coords.y);
    var bottomRight = new Vector2(coords.x + coords.width, coords.y + coords.height);
    return new List<Vector2> {topLeft, topRight, bottomLeft, bottomRight};
  }
  
  public Vector2[] AllUvs(int type) {
    var uvs = new List<Vector2>();
    for (var i = 0; i < 6; ++i) {
      uvs.AddRange(UvsFor(type, (Direction)i));
    }
    return uvs.ToArray();
  }
}