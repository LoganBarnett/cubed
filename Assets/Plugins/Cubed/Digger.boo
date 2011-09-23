import UnityEngine
import System.Linq.Enumerable

class Digger(MonoBehaviour):
  cubedObject as CubedObjectBehaviour
  public ignoreLayerNames as (string)
  
  layerMask as int
  mask = 0
  
  def Awake():
    cubedObjectGameObject = GameObject.Find("Cube Terrain")
    raise System.Exception("There must be a game object named 'Cube Terrain' on the scene for Digger to work") if cubedObjectGameObject == null
    cubedObject = cubedObjectGameObject.GetComponent of CubedObjectBehaviour()
    layerNumbers = ignoreLayerNames.Select({name| 1 << LayerMask.NameToLayer(name) })
    
    for n in layerNumbers:
      mask = mask | n
    
  def GetCubeAt(position as Vector3):
    return cubedObject.GetCubeAt(position)
    
  def Dig(ray as Ray, digDistance as single):
    hit = RaycastHit()
    return null unless Physics.Raycast(ray, hit, digDistance, ~mask)
    
    worldPoint = hit.point + (ray.direction * 0.1f) # need to overpenetrate a little
    block = cubedObject.RemoveCubeAt(worldPoint)
    cubedObject.GetChunkAt(worldPoint).Generate(cubedObject.Cubes)
    BroadcastMessage("DigComplete", block, SendMessageOptions.DontRequireReceiver) unless block == null
