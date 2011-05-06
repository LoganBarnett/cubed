import UnityEngine
import System.Linq.Enumerable

#import System.Collections.Generic

import Cubed

#[RequireComponent(MeshFilter)]
#[RequireComponent(MeshRenderer)]
#[RequireComponent(MeshCollider)]
class CubeTerrainBehaviour(MonoBehaviour): 
  public chunksHigh = 10
  public chunksWide = 10
  public chunkWidth = 10
  public chunkHeight = 10
  public chunkDepth = 10
  public blockWidth = 8f
  public material as Material
  public wallMaterial as Material
  public floorMaterial as Material
  public showWalls = true
  public showFloor = true
  public cubeDefinitions as (CubeDefinition)
  public packedTexture as Texture
  public textureAtlas as (Rect)
  
  public cubeLegend as CubeLegend
  
  public cubeTerrain as CubeTerrain;
  
  def Awake():
    cubeTerrain.Initialize()
    #Generate() if cubeTerrain == null
    
  def Generate():
    DestroyChildren() # patricide?
    # TODO: This is getting painful
    # Make chunk height/depth/width into WorldDimensions property
    cubeLegend = CubeLegend(TextureAtlas: textureAtlas, CubeDefinitions: cubeDefinitions)
    cubeTerrain = CubeTerrain(CubeWidth: blockWidth, ChunkWidth: chunkWidth, ChunkHeight: chunkHeight, ChunkDepth: chunkDepth, CubeMaterial: material, CubeLegend: cubeLegend)
    cubeTerrain.GameObject = gameObject
    # just create a full chunk for testing
    cubeTerrain.GenerateChunks(chunksWide, chunksHigh, cubeTerrain.GenerateFilledCubeGrid())
  
  def DestroyChildren():
    children = List of GameObject()
    for childTransform as Transform in transform:
      children.Add(childTransform.gameObject)
    for child in children:
      Debug.Log("Destroying ${child.name}")
      GameObject.DestroyImmediate(child)

  def GetCubeAt(position as Vector3):
    return cubeTerrain.GetCubeAt(position)
  
  def RemoveCubeAt(position as Vector3):
    cube = cubeTerrain.GetCubeAt(position)
    return null if cube == null
    return cube.Chunk.RemoveCube(cube.Indexes)
  
  def PlaceCubeAt(worldPosition as Vector3, cube as GameObject):
    cubePlacement = cubeTerrain.GetCubePointAt(worldPosition)
    cubeTerrain.PlaceCube(cubePlacement, cube)
