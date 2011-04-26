namespace Cubed
import UnityEngine;

class Vector3i:
  public x as int
  public y as int
  public z as int

  def constructor(newX as int, newY as int, newZ as int):
    x = newX
    y = newY
    z = newZ
  
  def constructor(vector as Vector3):
    x = cast(int, vector.x)
    y = cast(int, vector.y)
    z = cast(int, vector.z)
  
  static def op_Addition(vector as Vector3i, i as int):
    return Vector3i(vector.x + i, vector.y + i, vector.z + i)
    
  static def op_Subtraction(vector as Vector3i, i as int):
    return Vector3i(vector.x - i, vector.y - i, vector.z - i)
  
  static def op_Equality(vectorLeft as Vector3i, vectorRight as Vector3i):
    return vectorLeft.x == vectorRight.x and vectorLeft.y == vectorRight.y and vectorLeft.z == vectorRight.z
    
  def ToString():
    return "(${x}, ${y}, ${z})"
  
  # not sure how robust this is, should work for a large set of small numbers
  override def GetHashCode():
    return (x * 256) + (y * 16) + z
  
  override def Equals(obj as object):
    return obj as Vector3i == self
  
  Up as Vector3i:
    get:
      return Vector3i(x, y + 1, z)
      
  Down as Vector3i:
    get:
      return Vector3i(x, y - 1, z)
      
  Left as Vector3i:
    get:
      return Vector3i(x - 1, y, z)
      
  Right as Vector3i:
    get:
      return Vector3i(x + 1, y, z)
  
  Front as Vector3i:
    get:
      return Vector3i(x, y, z + 1)
  
  Back as Vector3i:
    get:
      return Vector3i(x, y, z - 1)