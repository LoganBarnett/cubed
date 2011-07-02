namespace Cubed

import UnityEngine
import System.Collections.Generic

[System.Serializable]
class Cube:
  [Property(Type)]
  public type = 0
  
  [Property(Vertices)]
  public vertices = List[of Vector3]()
  [Property(Triangles)]
  public triangles = List[of int]()
  [Property(Uvs)]
  public uvs = List of Vector2()
  
  [Property(Indexes)]
  public indexes as Vector3i
  [Property(Chunk)]
  public chunk as Chunk
  [Property(GameObject)]
  public gameObject as GameObject
  public layer as LayerMask
  
  # is there ever a desire to have a non-uniform grid size (x/y/z different)?
  [Property(CubeWidth)]
  blockWidth as single
  
  generateCollider = false
  
  def CreateCollision():
    self.gameObject = GameObject()
    gameObject.tag = "cubed_cube"
    gameObject.AddComponent of BoxCollider()
    collider = gameObject.collider as BoxCollider
    collider.size = Vector3(blockWidth, blockWidth, blockWidth)
    offsetInChunk = (Vector3(indexes.x, indexes.y, indexes.z) * blockWidth)
    halfSize = Vector3(blockWidth, blockWidth, blockWidth) / 2f
    if chunk:
      cubePosition = offsetInChunk + halfSize
      gameObject.transform.position = cubePosition
      gameObject.transform.parent = chunk.transform
    
    gameObject.layer = layer
    gameObject.AddComponent of CubeBehaviour().cube = self
    gameObject.name = GetCubeName(indexes)
  
  def Calculate(gridPosition as Vector3i, ref vertexCount as int, cubes as (Cube, 3), cubeLegend as CubeLegend):
    # TODO: Put this back in when preprocessor directives are supported in Boo
    # Use UNITY_EDITOR
    #CubeGeneratorProgressEditor.ReportCube(chunk.gridPosition, gridPosition) if chunk
    # clear out the old data
    vertices.Clear()
    triangles.Clear()
    uvs.Clear()

    chunkPosition = (chunk.transform.position if chunk else Vector3.zero)
    
    indexes = Vector3i() if not indexes
    position = Vector3(indexes.x - chunkPosition.x, indexes.y - chunkPosition.y, indexes.z - chunkPosition.z) * blockWidth

    AddBottom(position, vertexCount, cubeLegend) unless AdjacentCubeExists(cubes, indexes.Down)
    AddTop   (position, vertexCount, cubeLegend) unless AdjacentCubeExists(cubes, indexes.Up)
    AddRight (position, vertexCount, cubeLegend) unless AdjacentCubeExists(cubes, indexes.Right)
    AddLeft  (position, vertexCount, cubeLegend) unless AdjacentCubeExists(cubes, indexes.Left)
    AddFront (position, vertexCount, cubeLegend) unless AdjacentCubeExists(cubes, indexes.Front)
    AddBack  (position, vertexCount, cubeLegend) unless AdjacentCubeExists(cubes, indexes.Back)
    
    if gameObject:
      generateCollider = true
      GameObject.Destroy(gameObject)
    
    #CreateCollision() if generateCollider and cubeLegend.cubeDefinitions[type].hasCollision
  
  def GetCubeName(gridPosition as Vector3i):
    return "Cube Collider (${gridPosition.x}, ${gridPosition.y}, ${gridPosition.z})"
  
  def AddBottom(position as Vector3, ref vertexCount as int, cubeLegend as CubeLegend):
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
    Vertices.Add(position)
    Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))

    Uvs.AddRange(cubeLegend.UvsFor(type, Direction.Down))
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
  def AddTop(position as Vector3, ref vertexCount as int, cubeLegend as CubeLegend):
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
    
    Uvs.AddRange(cubeLegend.UvsFor(type, Direction.Up))
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
  def AddRight(position as Vector3, ref vertexCount as int, cubeLegend as CubeLegend):
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
    
    Uvs.AddRange(cubeLegend.UvsFor(type, Direction.Right))
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
  def AddLeft(position as Vector3, ref vertexCount as int, cubeLegend as CubeLegend):
    Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
    Vertices.Add(Vector3(position.x, position.y, position.z))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
 
    Uvs.AddRange(cubeLegend.UvsFor(type, Direction.Left))
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
  def AddFront(position as Vector3, ref vertexCount as int, cubeLegend as CubeLegend):
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
    Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
    
    Uvs.AddRange(cubeLegend.UvsFor(type, Direction.Front))
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
  def AddBack(position as Vector3, ref vertexCount as int, cubeLegend as CubeLegend):
    Vertices.Add(Vector3(position.x, position.y, position.z))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
    
    Uvs.AddRange(cubeLegend.UvsFor(type, Direction.Back))
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
#  def AddUvs():
#    Uvs.Add(Vector2(0f, 0f))
#    Uvs.Add(Vector2(0f, 1f))
#    Uvs.Add(Vector2(1f, 0f))
#    Uvs.Add(Vector2(1f, 1f)) 
#    
  def AddTriangles(vertexCount as int):
    # need this order to appear on outside of cube
    newTriangles = (0, 1, 2, 1, 3, 2) .Select({i| i + vertexCount})
    Triangles.AddRange(newTriangles)
  
  def GetCube(cubes as (Cube, 3), position as Vector3i):
    try:
      cube = cubes[position.x, position.y, position.z]
      return null if not cube
      return null if not cube.chunk
      return null if cube.chunk and (cube.chunk.gridPosition != chunk.gridPosition)
      return cube
    except e as System.IndexOutOfRangeException:
      return null
  
  def AdjacentCubeExists(cubes as (Cube, 3), adjacentPosition as Vector3i):
    return GetCube(cubes, adjacentPosition) != null
