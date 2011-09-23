import UnityEngine
import System.Linq.Enumerable
import System.Collections.Generic

#[RequireComponent(MeshFilter)]
#[RequireComponent(MeshRenderer)]
#[RequireComponent(MeshCollider)]
#[ExecuteInEditMode]
class CubedObjectBehaviour(MonoBehaviour): 
  public chunkDimensions = Vector3i(8,8,8)
  public dimensionsInChunks = Vector3i(1,1,1)
  public cubeSize = 1f
  public material as Material
  #public cubeDefinitions as (CubeDefinition)
  public packedTexture as Texture
  public textureAtlas as (Rect)
  public cubeLegend as CubeLegend
  #public cubedObject as CubedObject
  
  # oh Unity, if only you could serialize Dictionaries, I would love you longer than the stars
  # etc
  public chunkVectors as List of Vector3i
  public chunkChunks as List of Chunk
  public cubeVectors as List of Vector3i
  public cubeCubes as List of Cube
  
  Cubes as (Cube, 3):
    get:
      return allCubes
  
  chunks as Dictionary[of Vector3i, Chunk]
  allCubes as (Cube, 3)

  Chunks as Dictionary[of Vector3i, Chunk]:
    get:
      return chunks
  
  def Awake():
    Initialize()
  
  def Initialize():
    cubeDimensions = dimensionsInChunks * chunkDimensions
    allCubes = matrix(Cube, cubeDimensions.x, cubeDimensions.y, cubeDimensions.z)
    if cubeCubes:
      for cube in cubeCubes:
        allCubes[cube.Indexes.x, cube.Indexes.y, cube.Indexes.z] = cube

    chunks = Dictionary[of Vector3i, Chunk]()
    if chunkVectors and chunkChunks:
      for i in range(0, chunkVectors.Count):
        chunk = chunkChunks[i]
#        chunk.cubes = allCubes
        chunk.CubedObject = self
        chunks[chunkVectors[i]] = chunk
    
  def Generate(allCubes as (Cube, 3)):
    DestroyChildren() # patricide?
    cubeLegend = CubeLegend(TextureAtlas: textureAtlas, CubeDefinitions: cubeLegend.cubeDefinitions)
    GenerateChunks(dimensionsInChunks, allCubes, transform.position)
    for chunk in Chunks.Values:
      chunk.Generate(Cubes)
  
  def DestroyChildren():
    children = List of GameObject()
    for childTransform as Transform in transform:
      children.Add(childTransform.gameObject)
    for child in children:
      GameObject.DestroyImmediate(child)

  def GetCubeAt(gridPosition as Vector3i):
    try:
      return allCubes[gridPosition.x, gridPosition.y, gridPosition.z]
    except:
      raise System.IndexOutOfRangeException("Provided: ${gridPosition}\nDimensions: (${len(allCubes, 0)}, ${len(allCubes, 1)}, ${len(allCubes, 2)})")

  def GetCubeAt(position as Vector3):
    #chunk = GetChunkAt(position)
    #cube = chunk.GetCubeAt(GetCubePointAt(position))
    indexes = Vector3i(position.x / cubeSize, position.y / cubeSize, position.z / cubeSize)
    cube = Cubes[indexes.x, indexes.y, indexes.z]
    return cube  

  def RemoveCubeAt(cubeLocation as Vector3i):
    cube = allCubes[cubeLocation.x, cubeLocation.y, cubeLocation.z]
    if cube == null:
      raise System.Exception("Null cube found at ${cubeLocation}")

    allCubes[cubeLocation.x, cubeLocation.y, cubeLocation.z] = null
    return cube
    
  def RemoveCubeAt(position as Vector3):
    relativePosition = position - transform.position
    cube = GetCubeAt(relativePosition)
    return null if cube == null
    return RemoveCubeAt(cube.Indexes)
      
  def PlaceCubeAt(worldPosition as Vector3, cube as Cube):
    cubePlacement = GetGridPositionOf(worldPosition - transform.position)
    return PlaceCubeAt(cubePlacement, cube)
  
  def PlaceCubeAt(worldPosition as Vector3, cube as GameObject):
    cubePlacement = GetGridPositionOf(worldPosition - transform.position)
    return PlaceCubeAt(cubePlacement, cube)

  def MakeChunk():
    chunkGameObject = GameObject()
    chunkGameObject.AddComponent(MeshFilter)
    chunkGameObject.AddComponent(MeshRenderer)
    chunkGameObject.AddComponent(MeshCollider)
    chunkComponent = chunkGameObject.AddComponent(Chunk)
    chunkComponent.CubeWidth = cubeSize
    chunkComponent.CubeMaterial = material
    chunkGameObject.name = "Chunk"
    chunkGameObject.tag = "cubed_chunk"
    chunkComponent.CubeLegend = cubeLegend
    chunkGameObject.transform.parent = gameObject.transform
    #chunkGameObject.transform.localScale = Vector3.one
    return chunkGameObject

  def Generate():
    Generate(Cubes)
      
  def GetGridPositionOf(worldPosition as Vector3):
    cubePosition = worldPosition / cubeSize
    cubeIndexes = Vector3i(cubePosition)
    return cubeIndexes
    
  def Save():
    cubeCubes.Clear()
    cubeVectors.Clear()
    for cube in Cubes:
      cubeCubes.Add(cube)
      cubeVectors.Add(cube.indexes) if cube

  def GetChunkAt(position as Vector3):
    x = position.x / (chunkDimensions.x  * cubeSize)
    y = position.y / (chunkDimensions.y * cubeSize)
    z = position.z / (chunkDimensions.z  * cubeSize)
    key = Vector3i(x, y, z)
    return chunks[key]
    
  def GetChunkAt(position as Vector3i):
    return chunks[position]
    
  def PlaceCubeAt(indexes as Vector3i, cube as Cube):
    allCubes[indexes.x, indexes.y, indexes.z] = cube
    return cube

  def PlaceCubeAt(indexes as Vector3i, cubeGameObject as GameObject):
    originalCube = cubeGameObject.GetComponent of CubeBehaviour().cube
    cube = Cube(Indexes: indexes, CubeWidth: cubeSize, Type: originalCube.Type)
    cube.gameObject = cubeGameObject

    allCubes[indexes.x, indexes.y, indexes.z] = cube
    return cube

  def GenerateChunks(newDimensionsInChunks as Vector3i, cubes as (Cube, 3), offset as Vector3):
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
          GenerateChunk(location, cubes, offset)

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
         
  def GenerateChunk(location as Vector3i, cubes as (Cube, 3), offset as Vector3):
    # TODO: Put this back in when preprocessor directives are supported in Boo
    # Use UNITY_EDITOR
    #CubeGeneratorProgressEditor.ReportChunk(Vector3i(location.x, location.y, location.z))

    chunkGameObject = MakeChunk()
    chunkGameObject.transform.position = (Vector3(location.x * chunkDimensions.x, location.y * chunkDimensions.y, location.z * chunkDimensions.z) * cubeSize) + offset
    chunkGameObject.name = "Chunk ${location.x}, ${location.y}, ${location.z}"
    chunk = chunkGameObject.GetComponent of Chunk()

    chunk.CubedObject = self
    chunk.dimensionsInCubes = Vector3i(chunkDimensions.x, chunkDimensions.y, chunkDimensions.z)
    chunk.gridPosition = location
    chunks[location] = chunk
    chunk.Generate(cubes)