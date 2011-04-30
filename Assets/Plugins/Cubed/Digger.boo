import UnityEngine
import Cubed
import System.Linq.Enumerable

class Digger(MonoBehaviour):
  cubeTerrain as CubeTerrainBehaviour
  public ignoreLayerNames as (string)
  
  layerMask as int
  mask = 0
  
  def Awake():
    cubeTerrainGameObject = GameObject.Find("Cube Terrain")
    raise System.Exception("There must be a game object named 'Cube Terrain' on the scene for Digger to work") if cubeTerrainGameObject == null
    cubeTerrain = cubeTerrainGameObject.GetComponent of CubeTerrainBehaviour()
    layerNumbers = ignoreLayerNames.Select({name| 1 << LayerMask.NameToLayer(name) })
    
    for n in layerNumbers:
      mask = mask | n
    
  def GetCubeAt(position as Vector3):
    return cubeTerrain.GetCubeAt(position)
    
  def Dig(ray as Ray, digDistance as single):
    hit = RaycastHit()
    return null unless Physics.Raycast(ray, hit, digDistance, ~mask)
    
    worldPoint = hit.point + (ray.direction * 0.1f) # need to overpenetrate a little
    block = cubeTerrain.RemoveCubeAt(worldPoint)
    BroadcastMessage("DigComplete", block, SendMessageOptions.DontRequireReceiver) unless block == null
