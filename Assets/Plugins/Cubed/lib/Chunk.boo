import Cubed
import UnityEngine
#import System.Linq.Enumerable
import System.Collections.Generic

class Chunk(MonoBehaviour):
  public serializedCubes as List of Cube
  public cubes as (Cube, 3)
  public gridPosition as Vector3i
  public dimensionsInCubes as Vector3i
  public cubeObject as CubedObject
  
  [Property(CubeWidth)]
  public blockWidth = 10f
  
  [Property(CubeMaterial)]
  public blockMaterial as Material
  
  [Property(CubeLegend)]
  public cubeLegend as CubeLegend
  
#  def Awake():
#    for childTransform as Transform in transform:
#      cubeBehaviour = childTransform.gameObject.GetComponent of CubeBehaviour()
#      continue unless cubeBehaviour
#      indexes = cubeBehaviour.cube.indexes
#      cubes[indexes.x, indexes.y, indexes.z] = cubes.cube

  def Awake():
    # all for Unity's serialization
    #cubes = matrix(Cube, dimensionsInCubes.x, dimensionsInCubes.y, dimensionsInCubes.z)
    #for cube in serializedCubes:
      #cubes[cube.indexes.x, cube.indexes.y, cube.indexes.z] = cube
    #cubes = cubeObject.allCubes
    pass
  
  def CalculateRenderableCube(cube as Cube, ref vertexCount as int, cubes as (Cube, 3)):
    #gridPosition = Vector3i(x, y, z)
    #cube = cubes[x,y,z]
    return null if cube == null
    cube.CubeWidth = blockWidth
    #cube.Indexes = gridPosition
    
    cube.Chunk = self
    cube.Calculate(cube.indexes, vertexCount, cubes, cubeLegend)
    return cube
    
  def GenerateRenderableCubes(cubes as (Cube, 3)):
    vertexCount = 0
    begin = gridPosition * dimensionsInCubes
    end = begin + dimensionsInCubes
    for cubeX in range(begin.x, end.x):
      for cubeY in range(begin.y, end.y):
        for cubeZ in range(begin.z, end.z):
          cube = cubes[cubeX, cubeY, cubeZ]
          continue if cube == null
          cubes[cubeX, cubeY, cubeZ] = CalculateRenderableCube(cube, vertexCount, cubes)
    return cubes
  
  def Generate(cubesToGenerate as (Cube, 3)):
    begin = gridPosition * dimensionsInCubes
    end = begin + dimensionsInCubes
    if cubes != null:
      for x in range(begin.x, end.x):
        for y in range(begin.y, end.y):
          for z in range(begin.z, end.z):
            GameObject.Destroy(cubes[x,y,z].GameObject) if cubesToGenerate[x,y,z] == null and cubes[x,y,z] and cubes[x,y,z].GameObject

    for x in range(begin.x, end.x):
      for y in range(begin.y, end.y):
        for z in range(begin.z, end.z):
          cubesToGenerate[x,y,z].chunk = self if cubesToGenerate[x,y,z] 

    cubes = GenerateRenderableCubes(cubesToGenerate)
    vertices = List[of Vector3]()
    triangles = List[of int]()
    uvs = List of Vector2()
    #for block in cubes: # works well for matrixes

    for x in range(begin.x, end.x):
      for y in range(begin.y, end.y):
        for z in range(begin.z, end.z):
          cube = cubes[x, y, z]
          continue if not cube
          vertices.AddRange(cube.Vertices)
          triangles.AddRange(cube.Triangles)
          uvs.AddRange(cube.Uvs)

    renderer.materials = (blockMaterial,)
    
    meshFilter = GetComponent[of MeshFilter]()
    # sharedMesh is null during generation
    # TODO: Fix this as the generator shows errors in the console when using mesh vs. sharedMesh
    #mesh = (meshFilter.mesh if EditorApplication.isPlayingOrWillChangePlaymode else meshFilter.sharedMesh)
    mesh = meshFilter.mesh
    mesh.Clear()
    mesh.vertices = vertices.ToArray()
    mesh.triangles = triangles.ToArray()
    mesh.uv = uvs.ToArray()
    mesh.RecalculateNormals()
    
    serializedCubes = List of Cube()
    for cube in cubes:
      serializedCubes.Add(cube)
    
  def GetCubeAt(blockLocation as Vector3i):
    indexes = Vector3i(blockLocation.x / blockWidth, blockLocation.y / blockWidth, blockLocation.z / blockWidth)
    cube = cubes[indexes.x, indexes.y, indexes.z]
    return cube
  
  def AddCube(blockLocation as Vector3i, blockGameObject as GameObject):
    # TODO: fix the error - this doesn't actually catch anything
    raise System.Exception("Cannot add: A block already exists at ${blockLocation}") if cubes[blockLocation.x, blockLocation.y, blockLocation.z]
    #newCubes = cubes.Clone() as (Cube, 3)
    newCubes = cubes
    originalCube = blockGameObject.GetComponent of CubeBehaviour().cube
    cube = Cube(Indexes: blockLocation, CubeWidth: blockWidth, Chunk: self, GameObject: blockGameObject, Type: originalCube.Type)
    newCubes[blockLocation.x, blockLocation.y, blockLocation.z] = cube
    # TODO: Make a separate call
    Generate(newCubes)
    return cube
    
  def RemoveCube(cubeLocation as Vector3i):
    cube = cubes[cubeLocation.x, cubeLocation.y, cubeLocation.z]
    if cube == null:
      raise System.Exception("Null cube found at ${cubeLocation}")
    if cube.GameObject == null:
      raise System.Exception("Missing game object on block to be destroyed (${cube.Indexes.x}, ${cube.Indexes.y}, ${cube.Indexes.z})")
    GameObject.Destroy(cube.GameObject)
    #newCubes = cubes.Clone() as (Cube, 3)
    newCubes = cubes
    newCubes[cubeLocation.x, cubeLocation.y, cubeLocation.z] = null
    return cube