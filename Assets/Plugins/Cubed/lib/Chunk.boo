import Cubed
import UnityEngine
#import System.Linq.Enumerable
import System.Collections.Generic

class Chunk(MonoBehaviour):
  #serializedCubes as List of Cube
  public cubes as (Cube, 3)
  public gridPosition as Vector3i
  public dimensionsInCubes as Vector3i
  
  [Property(CubedObject)]
  cubeObject as CubedObject
  
  [Property(CubeWidth)]
  public cubeSize = 10f
  
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
  
  def CalculateRenderableCube(cube as Cube, ref vertexCount as int, cubes as (Cube, 3), gridPosition as Vector3i):
    #gridPosition = Vector3i(x, y, z)
    #cube = cubes[x,y,z]
    return null if cube == null
    cube.CubeWidth = cubeSize
    cube.indexes = gridPosition
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
          cubeGridPosition = Vector3i(cubeX, cubeY, cubeZ)
          cubes[cubeX, cubeY, cubeZ] = CalculateRenderableCube(cube, vertexCount, cubes, cubeGridPosition)
    return cubes
  
  def Generate(cubesToGenerate as (Cube, 3)):
    begin = gridPosition * dimensionsInCubes
    end = begin + dimensionsInCubes
#    if cubes != null:
#      for x in range(begin.x, end.x):
#        for y in range(begin.y, end.y):
#          for z in range(begin.z, end.z):
#            GameObject.Destroy(cubes[x,y,z].GameObject) if cubesToGenerate[x,y,z] == null and cubes[x,y,z] and cubes[x,y,z].GameObject

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
    
    meshCollider = collider as MeshCollider
    meshCollider.sharedMesh = mesh
    meshCollider.convex = false
    #serializedCubes = List of Cube()
    #for cube in cubes:
      #serializedCubes.Add(cube)
    
  def GetCubeAt(cubeLocation as Vector3i):
    indexes = Vector3i(cubeLocation.x / cubeSize, cubeLocation.y / cubeSize, cubeLocation.z / cubeSize)
    cube = cubes[indexes.x, indexes.y, indexes.z]
    return cube
  
  def AddCube(cubeLocation as Vector3i, cubeGameObject as GameObject):
    # TODO: fix the error - this doesn't actually catch anything
    raise System.Exception("Cannot add: A cube already exists at ${cubeLocation}") if cubes[cubeLocation.x, cubeLocation.y, cubeLocation.z]
    #newCubes = cubes.Clone() as (Cube, 3)
    originalCube = cubeGameObject.GetComponent of CubeBehaviour().cube
    cube = Cube(Indexes: cubeLocation, CubeWidth: cubeSize, Chunk: self, GameObject: cubeGameObject, Type: originalCube.Type)
    cubes[cubeLocation.x, cubeLocation.y, cubeLocation.z] = cube
    # TODO: Make a separate call
    Generate(cubes)
    return cube
    
  def AddCube(cubeLocation as Vector3i, cube as Cube):
    # TODO: fix the error - this doesn't actually catch anything
    raise System.Exception("Cannot add: A cube already exists at ${cubeLocation}") if cubes[cubeLocation.x, cubeLocation.y, cubeLocation.z]
    cubes[cubeLocation.x, cubeLocation.y, cubeLocation.z] = cube
    # TODO: Make a separate call
    Generate(cubes)
    return cube
    
  def RemoveCube(cubeLocation as Vector3i):
    cube = cubes[cubeLocation.x, cubeLocation.y, cubeLocation.z]
    if cube == null:
      raise System.Exception("Null cube found at ${cubeLocation}")

    cubes[cubeLocation.x, cubeLocation.y, cubeLocation.z] = null
    return cube