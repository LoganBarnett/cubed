namespace Cubed

import UnityEngine
import System.Collections.Generic

class Cube:
  [Property(Vertices)]
  vertices = List[of Vector3]()
  [Property(Triangles)]
  triangles = List[of int]()
  [Property(Uvs)]
  uvs = List of Vector2()
  
  [Property(Indexes)]
  indexes as Vector3i
  [Property(Chunk)]
  chunk as Chunk
  [Property(GameObject)]
  gameObject as GameObject
  
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
    blockPosition = chunk.transform.position + offsetInChunk + halfSize
    
    gameObject.AddComponent of CubeBehaviour().cube = self
    
    gameObject.transform.position = blockPosition
    gameObject.name = GetCubeName(indexes)
  
  def Calculate(gridPosition as Vector3i, ref vertexCount as int, cubes as (Cube, 3)):
    # clear out the old data
    vertices.Clear()
    triangles.Clear()
    uvs.Clear()
    
    vx = gridPosition.x * blockWidth
    vy = gridPosition.y * blockWidth
    vz = gridPosition.z * blockWidth
    
    position = Vector3(vx, vy, vz)
    
    AddBottom(position, vertexCount) unless AdjacentCubeExists(cubes, gridPosition.Down)
    AddTop(position, vertexCount)    unless AdjacentCubeExists(cubes, gridPosition.Up)
    AddRight(position, vertexCount)  unless AdjacentCubeExists(cubes, gridPosition.Right)
    AddLeft(position, vertexCount)   unless AdjacentCubeExists(cubes, gridPosition.Left)
    AddFront(position, vertexCount)  unless AdjacentCubeExists(cubes, gridPosition.Front)
    AddBack(position, vertexCount)   unless AdjacentCubeExists(cubes, gridPosition.Back)
    
    if gameObject:
      generateCollider = false 
      gameObject.active = true
      gameObject.name = GetCubeName(gridPosition)
      
    CreateCollision() if generateCollider
  
  def GetCubeName(gridPosition as Vector3i):
    return "Cube Collider (${gridPosition.x}, ${gridPosition.y}, ${gridPosition.z})"
  
  def AddBottom(position as Vector3, ref vertexCount as int):
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
    Vertices.Add(position)
    Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))

    AddUvs()
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
  def AddTop(position as Vector3, ref vertexCount as int):
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
    
    AddUvs()
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
  def AddRight(position as Vector3, ref vertexCount as int):
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
    
    AddUvs()
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
  def AddLeft(position as Vector3, ref vertexCount as int):
    
    Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
    Vertices.Add(Vector3(position.x, position.y, position.z))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
 
    AddUvs()
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
  def AddFront(position as Vector3, ref vertexCount as int):
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
    Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
    
    AddUvs()
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
  def AddBack(position as Vector3, ref vertexCount as int):
    Vertices.Add(Vector3(position.x, position.y, position.z))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
    
    AddUvs()
    AddTriangles(vertexCount)
    generateCollider = true
    vertexCount += 4;
  
  def AddUvs():
    Uvs.Add(Vector2(0f, 0f))
    Uvs.Add(Vector2(0f, 1f))
    Uvs.Add(Vector2(1f, 0f))
    Uvs.Add(Vector2(1f, 1f))
    
  def AddTriangles(vertexCount as int):
    # need this order to appear on outside of cube
    newTriangles = (0, 1, 2, 1, 3, 2) .Select({i| i + vertexCount})
    Triangles.AddRange(newTriangles)
  
  def GetCube(cubes as (Cube, 3), position as Vector3i):
    try:
      return cubes[position.x, position.y, position.z]
    except e as System.IndexOutOfRangeException:
      return null
  
  def AdjacentCubeExists(cubes as (Cube, 3), adjacentPosition as Vector3i):
    return GetCube(cubes, adjacentPosition) != null
