namespace Cubed

import UnityEngine
#import System.Linq.Enumerable
import System.Collections.Generic

[System.Serializable]
class CubeTerrain:
  [Property(GameObject)]
  public gameObject as GameObject
  
  [Property(CubeWidth)]
  public blockWidth as int #= 10f
  
  # TODO: Switch to this
  #[Property(ChunkDimensions)]
  #chunkDimensions as Vector3i
  [Property(ChunkWidth)]
  public chunkWidth as int #= 10
  [Property(ChunkHeight)]
  public chunkHeight as int #= 10
  [Property(ChunkDepth)]
  public chunkDepth  as int #= 10
  
  [Property(CubeLegend)]
  public cubeLegend as CubeLegend
  
  [Property(CubeMaterial)]
  public blockMaterial as Material
  
  # oh Unity, if only you could serialize Dictionaries, I would love you longer than the stars
  # etc
  public chunkVectors as List of Vector3i
  public chunkChunks as List of Chunk
  
  chunks as Dictionary[of Vector3i, Chunk]
  
#  [Property(CurrentProgress)]
#  currentProgress = 0
  
#  [Property(TotalProgress)]
#  totalProgress = 0
    
  def Initialize():
    chunks = Dictionary[of Vector3i, Chunk]()
    if chunkVectors and chunkChunks:
      for i in range(0, chunkVectors.Count - 1):
        chunks[chunkVectors[i]] = chunkChunks[i]
  
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
          cube = Cube()
          cube.Type = x % 2
          grid[x, y, z] = cube
    return grid
    
  def GenerateChunks(chunksWide as int, chunksDeep as int, cubes as (Cube, 3)):
    cubedObjectDimensions = Vector3i(chunksWide, chunksDeep, 0)
    chunkDimensions = Vector3i(chunkWidth, chunkHeight, chunkDepth)
    CubeGeneratorProgressEditor.Start(cubedObjectDimensions, chunkDimensions)
    
    chunks = Dictionary[of Vector3i, Chunk]()
    for x in range(chunksWide):
      for y in range(chunksDeep):
        GenerateChunk(x, y, null)
    
    chunkVectors = chunks.Keys.ToList()
    chunkChunks = chunks.Values.ToList()
    
    CubeGeneratorProgressEditor.End()
  
  def MakeChunk():
    chunkGameObject = GameObject()
    chunkGameObject.AddComponent(MeshFilter)
    chunkGameObject.AddComponent(MeshRenderer)
    chunkComponent = chunkGameObject.AddComponent(Chunk)
    chunkComponent.CubeWidth = blockWidth
    chunkComponent.CubeMaterial = blockMaterial
    chunkGameObject.name = "Chunk"
    chunkGameObject.tag = "cubed_chunk"
    chunkComponent.CubeLegend = cubeLegend
    chunkGameObject.transform.parent = gameObject.transform
    return chunkGameObject
    
  def GetCubePointAt(worldPosition as Vector3):
    blockPosition = worldPosition / blockWidth
    blockIndexes = Vector3i(blockPosition.x, blockPosition.y, blockPosition.z)
    return blockIndexes
        
  def GenerateChunk(x as int, y as int, cubes as (Cube, 3)):
    CubeGeneratorProgressEditor.ReportChunk(Vector3i(x, y, 0f))
    cubes = GenerateHalfFilledCubeGrid() if cubes == null
    
    chunkGameObject = MakeChunk()
    chunkGameObject.transform.position = Vector3(x * chunkWidth * blockWidth, 0f, y * chunkDepth * blockWidth)
    chunkGameObject.name = "Chunk ${x}, ${y}"
    chunk = chunkGameObject.GetComponent of Chunk()
    
    chunk.dimensionsInCubes = Vector3i(chunkWidth, chunkHeight, chunkDepth)
    chunk.x = x
    chunk.y = y
    chunks[Vector3i(x, 0, y)] = chunk
    chunk.Generate(cubes)

  
  def PlaceCube(indexes as Vector3i, cube as GameObject):
    x = indexes.x / chunkWidth
    y = indexes.z / chunkDepth
    chunk = chunks[Vector3i(x, 0, y)]
    relativeLocation = Vector3i(indexes.x - (chunkWidth * x), indexes.y, indexes.z - (chunkDepth * y))
    chunk.AddCube(relativeLocation, cube)
  
  def GetChunkAt(position as Vector3):
    x = position.x / (ChunkWidth * CubeWidth)
    y = position.y / (ChunkHeight * CubeWidth)
    z = position.z / (ChunkDepth * CubeWidth)
    key = Vector3i(x, y, z)
    return chunks[key]
    
  def GetCubeAt(position as Vector3):
#    chunkCollider = hit.collider as Collider # somehow Boo can't find the type, so specify it
#    blockBehaviour = chunkCollider.GetComponent of CubeBehaviour()
    
    #return null if blockBehaviour == null
    #chunk = blockBehaviour.cube.Chunk
    #return null if not chunk
    
    chunk = GetChunkAt(position)
    cube = chunk.GetCubeAt(GetCubePointAt(position))
    #Debug.Log("Found cube " + cube.GameObject.name)
    return cube