import UnityEngine

[System.Serializable]
class CubeDefinition:
  public type = 0
  public name = "cube"
  public hasCollision = false
  public front as Texture2D
  public back as Texture2D
  public left as Texture2D
  public right as Texture2D
  public top as Texture2D
  public bottom as Texture2D
  public paint = false
  
  Textures as (Texture2D):
    get:
      return (front, back, left, right, top, bottom)