import UnityEngine
import Cubed

class Digger(MonoBehaviour):
  public digDistance = 10f
  
  blockTerrain as BlockTerrainBehaviour
  
  def Awake():
    blockTerrainGameObject = GameObject.Find("Block Terrain")
    raise System.Exception("There must be a game object named 'Block Terrain' on the scene for Digger to work") if blockTerrainGameObject == null
    blockTerrain = blockTerrainGameObject.GetComponent of BlockTerrainBehaviour()
    
  def Update():
    Debug.DrawRay(Camera.main.transform.position, Camera.main.transform.forward * digDistance, Color.green)
    if Input.GetButtonDown("Dig"):
      block = blockTerrain.RemoveBlockAt(Ray(Camera.main.transform.position, Camera.main.transform.forward), digDistance)
