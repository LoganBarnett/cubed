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
  public cubedObject as CubedObject
  
  def Awake():
    cubedObject.Initialize() if cubedObject
    #Generate() if cubedObject == null
    
  def Generate(allCubes as (Cube, 3)):
    DestroyChildren() # patricide?
    # TODO: This is getting painful
    # Make chunk height/depth/width into WorldDimensions property
    cubeLegend = CubeLegend(TextureAtlas: textureAtlas, CubeDefinitions: cubeDefinitions)
    cubedObject = CubedObject()
    cubedObject.cubeSize = cubeSize
    cubedObject.chunkDimensions = chunkDimensions
    cubedObject.dimensionsInChunks = dimensionsInChunks
    cubedObject.cubeMaterial = material
    cubedObject.cubeLegend = cubeLegend
    cubedObject.gameObject = gameObject
    # just create a full chunk for testing
    #Debug.Log(allCubes == null)
    cubedObject.GenerateChunks(dimensionsInChunks, allCubes)
  
  def DestroyChildren():
    children = List of GameObject()
    for childTransform as Transform in transform:
      children.Add(childTransform.gameObject)
    for child in children:
      GameObject.DestroyImmediate(child)
  
  def GetChunkAt(position as Vector3):
    return cubedObject.GetChunkAt(position)

  def GetCubeAt(position as Vector3):
    return cubedObject.GetCubeAt(position)
  
  def RemoveCubeAt(position as Vector3):
    cube = cubedObject.GetCubeAt(position)
    return null if cube == null
    return cube.Chunk.RemoveCube(cube.Indexes)
  
  def PlaceCubeAt(worldPosition as Vector3, cube as GameObject):
    cubePlacement = cubedObject.GetCubePointAt(worldPosition)
    cubedObject.PlaceCube(cubePlacement, cube)