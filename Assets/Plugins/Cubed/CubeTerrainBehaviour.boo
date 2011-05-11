import UnityEngine
import System.Linq.Enumerable

#import System.Collections.Generic

import Cubed

#[RequireComponent(MeshFilter)]
#[RequireComponent(MeshRenderer)]
#[RequireComponent(MeshCollider)]
class CubeTerrainBehaviour(MonoBehaviour): 
  public chunkDimensions = Vector3i(8,8,8)
  public dimensionsInChunks = Vector3i(1,1,1)
  public cubeSize = 1f
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
    
  def Generate(allCubes as (Cube, 3)):
    DestroyChildren() # patricide?
    # TODO: This is getting painful
    # Make chunk height/depth/width into WorldDimensions property
    cubeLegend = CubeLegend(TextureAtlas: textureAtlas, CubeDefinitions: cubeDefinitions)
    cubeTerrain = CubeTerrain()
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

  def GetCubeAt(position as Vector3):
    return cubeTerrain.GetCubeAt(position)
  
  def RemoveCubeAt(position as Vector3):
    cube = cubeTerrain.GetCubeAt(position)
    return null if cube == null
    return cube.Chunk.RemoveCube(cube.Indexes)
  
  def PlaceCubeAt(worldPosition as Vector3, cube as GameObject):
    cubePlacement = cubeTerrain.GetCubePointAt(worldPosition)
    cubeTerrain.PlaceCube(cubePlacement, cube)

  def GenerateFilledCubeGrid():
    totalX = chunkDimensions.x * dimensionsInChunks.x
    totalY = chunkDimensions.y * dimensionsInChunks.y
    totalZ = chunkDimensions.z * dimensionsInChunks.z
    grid = matrix(Cube, totalX, totalY, totalZ)
    for x in range(totalX):
      for y in range(totalY):
        for z in range(totalZ):
          cube = Cube()
          cube.indexes = Vector3i(x,y,z)
          grid[x, y, z] = cube
    return grid

  def GenerateHalfFilledCubeGrid():
    totalX = chunkDimensions.x * dimensionsInChunks.x
    totalY = chunkDimensions.y * dimensionsInChunks.y
    totalZ = chunkDimensions.z * dimensionsInChunks.z
    grid = matrix(Cube, totalX, totalY, totalZ)
    for x in range(totalX):
      for y in range(totalY):
        continue if y > (totalY - 1) / 2 
        for z in range(totalZ):
          cube = Cube()
          cube.Type = x % 2
          cube.indexes = Vector3i(x,y,z)
          grid[x, y, z] = cube
    return grid
    
  def GenerateVertexStressTestGrid():
      totalX = chunkDimensions.x * dimensionsInChunks.x
      totalY = chunkDimensions.y * dimensionsInChunks.y
      totalZ = chunkDimensions.z * dimensionsInChunks.z
      grid = matrix(Cube, totalX, totalY, totalZ) 
      for x in range(totalX):
        for y in range(totalY):
          for z in range(totalZ):
            continue if (x % 2 == 1 and z % 2 == 1 and y % 2 == 0) or (x % 2 == 0 and z % 2 == 1 and y % 2 == 1) or (x % 2 == 1 and z % 2 == 0 and y % 2 == 1) #or (x % 2 == 1 and z % 2 == 1 and y % 2 == 0)
            cube = Cube()
            cube.Type = x % 2
            cube.indexes = Vector3i(x,y,z)
            grid[x, y, z] = cube
      return grid