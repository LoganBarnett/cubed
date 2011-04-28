namespace Cubed

import UnityEngine
#import System.Linq.Enumerable
import System.Collections.Generic

class CubeTerrain:
  [Property(CubeWidth)]
  blockWidth = 10f
  
  # TODO: Switch to this
  #[Property(ChunkDimensions)]
  #chunkDimensions as Vector3i
  [Property(ChunkWidth)]
  chunkWidth = 10
  [Property(ChunkHeight)]
  chunkHeight = 10
  [Property(ChunkDepth)]
  chunkDepth = 10
  
  [Property(CubeLegend)]
  cubeLegend as CubeLegend
  
  [Property(CubeMaterial)]
  blockMaterial as Material
  
  chunks = Dictionary[of Vector3i, Chunk]()

  
#  [Property(CurrentProgress)]
#  currentProgress = 0
  
#  [Property(TotalProgress)]
#  totalProgress = 0
  
  
  def GenerateFilledCubeGrid():
    grid = matrix(Cube, ChunkWidth, ChunkHeight, ChunkDepth)
    for x in range(ChunkWidth):
      for y in range(ChunkHeight):
        for z in range(ChunkDepth):
          grid[x, y, z] = Cube()
    return grid
    
  def GenerateHalfFilledCubeGrid():
    grid = matrix(Cube, ChunkWidth, ChunkHeight, ChunkDepth)
    for x in range(ChunkWidth):
      for y in range(ChunkHeight / 2):
        for z in range(ChunkDepth):
          grid[x, y, z] = Cube()
    return grid
    
  def GenerateChunks(chunksWide as int, chunksDeep as int, cubes as (Cube, 3)):
    for x in range(chunksWide):
      for y in range(chunksDeep):
        GenerateChunk(x, y, null)
  
  def MakeChunk():
    gameObject = GameObject()
    gameObject.AddComponent(MeshFilter)
    gameObject.AddComponent(MeshRenderer)
    chunkComponent = gameObject.AddComponent(Chunk)
    chunkComponent.CubeWidth = blockWidth
    chunkComponent.CubeMaterial = blockMaterial
    gameObject.name = "Chunk"
    gameObject.tag = "cubed_chunk"
    chunkComponent.CubeLegend = cubeLegend
    return gameObject
    
  def GetCubePointAt(worldPosition as Vector3):
    blockPosition = worldPosition / blockWidth
    blockIndexes = Vector3i(blockPosition.x, blockPosition.y, blockPosition.z)
    return blockIndexes
        
  def GenerateChunk(x as int, y as int, cubes as (Cube, 3)):
    cubes = GenerateHalfFilledCubeGrid() if cubes == null
    
    chunkGameObject = MakeChunk()
    chunkGameObject.transform.position = Vector3(x * chunkWidth * blockWidth, 0f, y * chunkDepth * blockWidth)
    chunkGameObject.name = "Chunk ${x}, ${y}"
    chunk = chunkGameObject.GetComponent of Chunk()
    chunk.x = x
    chunk.y = y
    chunks[Vector3i(x, 0, y)] = chunk
    chunk.Generate(cubes)
  
  def GetCubePlacement(ray as Ray, distance as single):
    # cast a ray
    #determine the block hit
    # determine which side of block hit
    # give back location of block
    hit = RaycastHit()
    return null unless Physics.Raycast(ray, hit, distance)

    worldPoint = hit.point - (ray.direction * 0.1f) # need to underpenetrate a little
    
    chunkCollider = hit.collider as Collider # somehow Boo can't find the type, so specify it
    blockBehaviour = chunkCollider.GetComponent of CubeBehaviour()
    return null if blockBehaviour == null
#    chunk = blockBehaviour.cube.Chunk
    vector = GetCubePointAt(worldPoint)
    return vector
    
  def PlaceCube(indexes as Vector3i, cube as GameObject):
    x = indexes.x / chunkWidth
    y = indexes.z / chunkDepth
    chunk = chunks[Vector3i(x, 0, y)]
    relativeLocation = Vector3i(indexes.x - (chunkWidth * x), indexes.y, indexes.z - (chunkDepth * y))
    chunk.AddCube(relativeLocation, cube)
      
  def GetCubeAt(ray as Ray, distance as single):
    hit = RaycastHit()
    return null unless Physics.Raycast(ray, hit, distance)
    
    worldPoint = hit.point + (ray.direction * 0.1f) # need to overpenetrate a little
    chunkCollider = hit.collider as Collider # somehow Boo can't find the type, so specify it
    blockBehaviour = chunkCollider.GetComponent of CubeBehaviour()
    return null if blockBehaviour == null
    chunk = blockBehaviour.cube.Chunk
    return null if not chunk
    cube = chunk.GetCubeAt(GetCubePointAt(worldPoint))
    return cube