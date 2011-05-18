import UnityEngine
import System.Linq.Enumerable

#import System.Collections.Generic

import Cubed

#[RequireComponent(MeshFilter)]
#[RequireComponent(MeshRenderer)]
#[RequireComponent(MeshCollider)]
[ExecuteInEditMode]
class CubedObjectBehaviour(MonoBehaviour): 
  public chunkDimensions = Vector3i(8,8,8)
  public dimensionsInChunks = Vector3i(1,1,1)
  public cubeSize = 1f
  public material as Material
#  public wallMaterial as Material
#  public floorMaterial as Material
#  public showWalls = true
#  public showFloor = true
  public cubeDefinitions as (CubeDefinition)
  public packedTexture as Texture
  public textureAtlas as (Rect)
  public cubeLegend as CubeLegend
  public cubeTerrain as CubedObject
  
  def Awake():
    cubeTerrain.Initialize() if cubeTerrain
    #Generate() if cubeTerrain == null
    
  def Generate(allCubes as (Cube, 3)):
    DestroyChildren() # patricide?
    # TODO: This is getting painful
    # Make chunk height/depth/width into WorldDimensions property
    cubeLegend = CubeLegend(TextureAtlas: textureAtlas, CubeDefinitions: cubeDefinitions)
    cubeTerrain = CubedObject()
    cubeTerrain.cubeSize = cubeSize
    cubeTerrain.chunkDimensions = chunkDimensions
    cubeTerrain.dimensionsInChunks = dimensionsInChunks
    cubeTerrain.cubeMaterial = material
    cubeTerrain.cubeLegend = cubeLegend
    cubeTerrain.gameObject = gameObject
    # just create a full chunk for testing
    #Debug.Log(allCubes == null)
    cubeTerrain.GenerateChunks(dimensionsInChunks, allCubes)
  
  def DestroyChildren():
    children = List of GameObject()
    for childTransform as Transform in transform:
      children.Add(childTransform.gameObject)
    for child in children:
      GameObject.DestroyImmediate(child)
  
  def GetChunkAt(position as Vector3):
    return cubeTerrain.GetChunkAt(position)

  def GetCubeAt(position as Vector3):
    return cubeTerrain.GetCubeAt(position)
  
  def RemoveCubeAt(position as Vector3):
    cube = cubeTerrain.GetCubeAt(position)
    return null if cube == null
    return cube.Chunk.RemoveCube(cube.Indexes)
  
  def PlaceCubeAt(worldPosition as Vector3, cube as GameObject):
    cubePlacement = cubeTerrain.GetCubePointAt(worldPosition)
    cubeTerrain.PlaceCube(cubePlacement, cube)