namespace Cubed
import UnityEngine
import System.Linq.Enumerable

[System.Serializable]
class CubeDefinition:
  public type = 0
  public name = "cube"
  public front as Material
  public back as Material
  public left as Material
  public right as Material
  public top as Material
  public bottom as Material
  
  def Materials() as (Material):
    return (front, back, left, right, top, bottom)
    
  Textures as (Texture2D):
    get:
      return Materials().Select({m| m.mainTexture as Texture2D}).ToArray()