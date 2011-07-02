namespace Cubed

import UnityEngine
import System.Linq.Enumerable
import System.Collections.Generic

[System.Serializable]
class CubedObject:
  public gameObject as GameObject
  public cubeSize as int #= 10f
  public chunkDimensions as Vector3i
  public dimensionsInChunks as Vector3i
  public cubeLegend as CubeLegend
  public cubeMaterial as Material
  
  
  # oh Unity, if only you could serialize Dictionaries, I would love you longer than the stars
  # etc
  public chunkVectors as List of Vector3i
  public chunkChunks as List of Chunk
  public cubeVectors as List of Vector3i
  public cubeCubes as List of Cube
  
  chunks as Dictionary[of Vector3i, Chunk]
  allCubes as (Cube, 3)
  
  Chunks as Dictionary[of Vector3i, Chunk]:
    get:
      return chunks
      
  Cubes as (Cube, 3):
    get:
      return allCubes
  
#  [Property(CurrentProgress)]
#  currentProgress = 0
  
#  [Property(TotalProgress)]
#  totalProgress = 0
    
  def Initialize():
    cubeDimensions = dimensionsInChunks * chunkDimensions
    allCubes = matrix(Cube, cubeDimensions.x, cubeDimensions.y, cubeDimensions.z)
    if cubeVectors and cubeCubes:
      for i in range(0, cubeVectors.Count):
        indexes = cubeVectors[i]
        allCubes[indexes.x, indexes.y, indexes.z] = cubeCubes[i]
        
    chunks = Dictionary[of Vector3i, Chunk]()
    if chunkVectors and chunkChunks:
      for i in range(0, chunkVectors.Count):
        chunk = chunkChunks[i]
        chunk.cubes = allCubes
        chunks[chunkVectors[i]] = chunk
    
  def GenerateChunks(newDimensionsInChunks as Vector3i, cubes as (Cube, 3)):
    allCubes = cubes
      
    dimensionsInChunks = newDimensionsInChunks
    # TODO: Put this back in when preprocessor directives are supported in Boo
    # Use UNITY_EDITOR
    #CubeGeneratorProgressEditor.Start(dimensionsInChunks, chunkDimensions)
    
    chunks = Dictionary[of Vector3i, Chunk]()
    #i = 0  
    for x in range(dimensionsInChunks.x):
      for y in range(dimensionsInChunks.y):
        for z in range(dimensionsInChunks.z):
          location = Vector3i(x, y, z)
          GenerateChunk(location, cubes)
    
    chunkVectors = chunks.Keys.ToList()
    chunkChunks = chunks.Values.ToList()
    
    cubeVectors = List of Vector3i()
    cubeCubes = List of Cube()
    for cube in cubes:
      continue if not cube
      cubeCubes.Add(cube)
      cubeVectors.Add(cube.indexes)
    # TODO: Put this back in when preprocessor directives are supported in Boo
    # Use UNITY_EDITOR
    #CubeGeneratorProgressEditor.End()
  
  def MakeChunk():
    chunkGameObject = GameObject()
    chunkGameObject.AddComponent(MeshFilter)
    chunkGameObject.AddComponent(MeshRenderer)
    chunkGameObject.AddComponent(MeshCollider)
    chunkComponent = chunkGameObject.AddComponent(Chunk)
    chunkComponent.CubeWidth = cubeSize
    chunkComponent.CubeMaterial = cubeMaterial
    chunkGameObject.name = "Chunk"
    chunkGameObject.tag = "cubed_chunk"
    chunkComponent.CubeLegend = cubeLegend
    chunkGameObject.transform.parent = gameObject.transform
    return chunkGameObject
    
  def GetCubePointAt(worldPosition as Vector3):
    cubePosition = worldPosition / cubeSize
    cubeIndexes = Vector3i(cubePosition.x, cubePosition.y, cubePosition.z)
    return cubeIndexes
        
  def GenerateChunk(location as Vector3i, cubes as (Cube, 3)):
    # TODO: Put this back in when preprocessor directives are supported in Boo
    # Use UNITY_EDITOR
    #CubeGeneratorProgressEditor.ReportChunk(Vector3i(location.x, location.y, location.z))
    
    chunkGameObject = MakeChunk()
    chunkGameObject.transform.position = Vector3(location.x * chunkDimensions.x * cubeSize, location.y * chunkDimensions.y * cubeSize, location.z * chunkDimensions.z * cubeSize)
    chunkGameObject.name = "Chunk ${location.x}, ${location.y}, ${location.z}"
    chunk = chunkGameObject.GetComponent of Chunk()
    
    chunk.CubedObject = self
    chunk.dimensionsInCubes = Vector3i(chunkDimensions.x, chunkDimensions.y, chunkDimensions.z)
    chunk.gridPosition = location
    chunks[location] = chunk
    chunk.Generate(cubes)

  
  def PlaceCube(indexes as Vector3i, cube as GameObject):
    x = indexes.x / chunkDimensions.x
    y = indexes.y / chunkDimensions.y
    z = indexes.z / chunkDimensions.z
    chunk = chunks[Vector3i(x, y, z)]
    chunk.AddCube(indexes, cube)
    
  def PlaceCube(indexes as Vector3i, cube as Cube):
    x = indexes.x / chunkDimensions.x
    y = indexes.y / chunkDimensions.y
    z = indexes.z / chunkDimensions.z
    chunk = chunks[Vector3i(x, y, z)]
    chunk.AddCube(indexes, cube)
  
  def GetChunkAt(position as Vector3):
    x = position.x / (chunkDimensions.x  * cubeSize)
    y = position.y / (chunkDimensions.y * cubeSize)
    z = position.z / (chunkDimensions.z  * cubeSize)
    key = Vector3i(x, y, z)
    return chunks[key]
    
  def GetCubeAt(gridPosition as Vector3i):
    return allCubes[gridPosition.x, gridPosition.y, gridPosition.z]
    
  def GetCubeAt(position as Vector3):
    #chunk = GetChunkAt(position)
    #cube = chunk.GetCubeAt(GetCubePointAt(position))
    indexes = Vector3i(position.x / cubeSize, position.y / cubeSize, position.z / cubeSize)
    cube = Cubes[indexes.x, indexes.y, indexes.z]
    return cube