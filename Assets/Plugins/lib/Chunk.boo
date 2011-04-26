namespace Cubed

import UnityEngine
#import System.Linq.Enumerable
import System.Collections.Generic

class Chunk(MonoBehaviour):
  public cubes as (Cube, 3)
  public x = 0
  public y = 0
  
  [Property(CubeWidth)]
  blockWidth = 10f
  
  [Property(CubeMaterial)]
  blockMaterial as Material
  
  [Property(CubeLegend)]
  cubeLegend as CubeLegend
  
  def CalculateRenderableCube(x as int, y as int, z as int, ref vertexCount as int, cubes as (Cube, 3)):
    gridPosition = Vector3i(x, y, z)
    cube = cubes[x,y,z]
    return null if cube == null
    cube.CubeWidth = blockWidth
    cube.Indexes = gridPosition
    
    cube.Chunk = self
    cube.Calculate(gridPosition, vertexCount, cubes, cubeLegend)
    return cube
    
  def GenerateRenderableCubes(cubes as (Cube, 3)):
    vertexCount = 0
    for x in range(len(cubes, 0)):
      for y in range(len(cubes, 1)):
        for z in range(len(cubes, 2)):
          cubes[x,y,z] = CalculateRenderableCube(x, y, z, vertexCount, cubes)
    return cubes
  
  def Generate(cubesToGenerate as (Cube, 3)):
    if cubes != null:
      for x in range(len(cubes, 0)):
        for y in range(len(cubes, 1)):
          for z in range(len(cubes, 2)):
            GameObject.Destroy(cubes[x,y,z].GameObject) if cubesToGenerate[x,y,z] == null and cubes[x,y,z] and cubes[x,y,z].GameObject != null


    cubes = GenerateRenderableCubes(cubesToGenerate)
    vertices = List[of Vector3]()
    triangles = List[of int]()
    uvs = List of Vector2()
    for block in cubes: # works well for matrixes
      continue if block == null
      vertices.AddRange(block.Vertices)
      triangles.AddRange(block.Triangles)
      uvs.AddRange(block.Uvs)

    renderer.materials = (blockMaterial,)
    
    meshFilter = GetComponent[of MeshFilter]()
    meshFilter.mesh.Clear()
    meshFilter.mesh.vertices = vertices.ToArray()
    meshFilter.mesh.triangles = triangles.ToArray()
    meshFilter.mesh.uv = uvs.ToArray()
    meshFilter.mesh.RecalculateNormals()
    
  def GetCubeAt(blockLocation as Vector3i):
    return cubes[blockLocation.x - (x * len(cubes, 0)), blockLocation.y, blockLocation.z - (y * len(cubes, 1))]
  
  def AddCube(blockLocation as Vector3i, blockGameObject as GameObject):
    # TODO: fix the error - this doesn't actually catch anything
    raise System.Exception("Cannot add: A block already exists at ${blockLocation}") if cubes[blockLocation.x, blockLocation.y, blockLocation.z] != null
    newCubes = cubes.Clone() as (Cube, 3)
    cube = Cube(CubeWidth: blockWidth, Chunk: self, GameObject: blockGameObject)
    newCubes[blockLocation.x, blockLocation.y, blockLocation.z] = cube
    Generate(newCubes)
    return cube
    
  def RemoveCube(blockLocation as Vector3i):
    block = cubes[blockLocation.x, blockLocation.y, blockLocation.z]
    if block.GameObject == null:
      raise System.Exception("Missing game object on block to be destroyed (${block.Indexes.x}, ${block.Indexes.y}, ${block.Indexes.z})")
    GameObject.Destroy(block.GameObject)
    newCubes = cubes.Clone() as (Cube, 3)
    newCubes[blockLocation.x, blockLocation.y, blockLocation.z] = null
    Generate(newCubes)
    return block