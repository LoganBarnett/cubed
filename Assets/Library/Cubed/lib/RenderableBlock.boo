namespace Cubed

import UnityEngine
import System.Collections.Generic

class RenderableBlock:
  [Property(Vertices)]
  vertices = List[of Vector3]()
  
  [Property(Triangles)]
  triangles = List[of int]()
  
  # is there ever a desire to have a non-uniform grid size (x/y/z different)?
  [Property(BlockWidth)]
  blockWidth as single
  
  def CalculateRenderableProperties(gridPosition as Vector3i, ref vertexCount as int, blocks as (Block, 3)):
    vx = gridPosition.x * blockWidth
    vy = gridPosition.y * blockWidth
    vz = gridPosition.z * blockWidth
    
    position = Vector3(vx, vy, vz)
    
    AddBottom(position, vertexCount) unless AdjacentBlockExists(blocks, gridPosition.Down)
    AddTop(position, vertexCount)    unless AdjacentBlockExists(blocks, gridPosition.Up)
    AddRight(position, vertexCount)  unless AdjacentBlockExists(blocks, gridPosition.Right)
    AddLeft(position, vertexCount)   unless AdjacentBlockExists(blocks, gridPosition.Left)
    AddFront(position, vertexCount)  unless AdjacentBlockExists(blocks, gridPosition.Front)
    AddBack(position, vertexCount)   unless AdjacentBlockExists(blocks, gridPosition.Back)
  
  def AddBottom(position as Vector3, ref vertexCount as int):
    Vertices.Add(position)
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
    Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
    
    AddTriangles(vertexCount)
    vertexCount += 4;
  
  def AddTop(position as Vector3, ref vertexCount as int):
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
    
    AddTriangles(vertexCount)
    vertexCount += 4;
  
  def AddRight(position as Vector3, ref vertexCount as int):
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
    
    AddTriangles(vertexCount)
    vertexCount += 4;
  
  def AddLeft(position as Vector3, ref vertexCount as int):
    Vertices.Add(Vector3(position.x, position.y, position.z))
    Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
    
    AddTriangles(vertexCount)
    vertexCount += 4;
  
  def AddFront(position as Vector3, ref vertexCount as int):
    Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
    
    AddTriangles(vertexCount)
    vertexCount += 4;
  
  def AddBack(position as Vector3, ref vertexCount as int):
    Vertices.Add(Vector3(position.x, position.y, position.z))
    Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
    Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
    
    AddTriangles(vertexCount)
    vertexCount += 4;
  
  def AddTriangles(vertexCount as int):
    # need this order to appear on outside of cube
    newTriangles = (0, 1, 2, 1, 3, 2) .Select({i| i + vertexCount})
    Triangles.AddRange(newTriangles)
  
  def GetBlock(blocks as (Block, 3), position as Vector3i):
    try:
      return blocks[position.x, position.y, position.z]
    except e as System.IndexOutOfRangeException:
      return null
  
  def AdjacentBlockExists(blocks as (Block, 3), adjacentPosition as Vector3i):
      return GetBlock(blocks, adjacentPosition) != null
    