import UnityEngine
import Cubed

class Digger(MonoBehaviour):
  cubeTerrain as CubeTerrainBehaviour
  
  def Awake():
    cubeTerrainGameObject = GameObject.Find("Cube Terrain")
    raise System.Exception("There must be a game object named 'Cube Terrain' on the scene for Digger to work") if cubeTerrainGameObject == null
    cubeTerrain = cubeTerrainGameObject.GetComponent of CubeTerrainBehaviour()
    
  def GetCubeAt(ray as Ray, digDistance as single):
    return cubeTerrain.GetCubeAt(ray, digDistance)
    
  def Dig(ray as Ray, digDistance as single):
    block = cubeTerrain.RemoveCubeAt(ray, digDistance)
    BroadcastMessage("DigComplete", block, SendMessageOptions.DontRequireReceiver) unless block == null
