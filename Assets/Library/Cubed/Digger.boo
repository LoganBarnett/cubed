import UnityEngine
import Cubed

class Digger(MonoBehaviour):
  blockTerrain as BlockTerrainBehaviour
  
  def Awake():
    blockTerrainGameObject = GameObject.Find("Block Terrain")
    raise System.Exception("There must be a game object named 'Block Terrain' on the scene for Digger to work") if blockTerrainGameObject == null
    blockTerrain = blockTerrainGameObject.GetComponent of BlockTerrainBehaviour()
    
  def GetBlockAt(ray as Ray, digDistance as single):
    return blockTerrain.GetBlockAt(ray, digDistance)
    
  def Dig(ray as Ray, digDistance as single):
    block = blockTerrain.RemoveBlockAt(ray, digDistance)
    BroadcastMessage("DigComplete", block, SendMessageOptions.DontRequireReceiver) unless block == null
