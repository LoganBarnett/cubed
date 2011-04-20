namespace Cubed

import UnityEngine
#import System.Linq.Enumerable
import System.Collections.Generic

class Chunk(MonoBehaviour):
  public blocks as (Block, 3)
  
  [Property(BlockWidth)]
  blockWidth = 10f
  
  [Property(BlockMaterial)]
  blockMaterial as Material
  
  def CalculateRenderableBlock(x as int, y as int, z as int, ref vertexCount as int, blocks as (Block, 3)):
    gridPosition = Vector3i(x, y, z)
    block = blocks[x,y,z]
    return null if block == null
    block.BlockWidth = blockWidth
    block.Indexes = gridPosition
    
    block.Chunk = self
    block.Calculate(gridPosition, vertexCount, blocks)
    return block
    
  def GenerateRenderableBlocks(blocks as (Block, 3)):
    vertexCount = 0
    for x in range(len(blocks, 0)):
      for y in range(len(blocks, 1)):
        for z in range(len(blocks, 2)):
          blocks[x,y,z] = CalculateRenderableBlock(x, y, z, vertexCount, blocks)
    return blocks
  
  def Generate(blocksToGenerate as (Block, 3)):
    if blocks != null:
      for x in range(len(blocks, 0)):
        for y in range(len(blocks, 1)):
          for z in range(len(blocks, 2)):
            GameObject.Destroy(blocks[x,y,z].GameObject) if blocksToGenerate[x,y,z] == null and blocks[x,y,z] and blocks[x,y,z].GameObject != null


    blocks = GenerateRenderableBlocks(blocksToGenerate)
    vertices = List[of Vector3]()
    triangles = List[of int]()
    uvs = List of Vector2()
    for block in blocks: # works well for matrixes
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
    
  def GetBlockAt(worldPosition as Vector3):
    localPosition = worldPosition - transform.position

    blockPosition = localPosition / blockWidth
    blockIndexes = Vector3i(blockPosition.x, blockPosition.y, blockPosition.z)
    block = blocks[blockIndexes.x, blockIndexes.y, blockIndexes.z]
    return block
    
  def RemoveBlock(blockLocation as Vector3i):
    block = blocks[blockLocation.x, blockLocation.y, blockLocation.z]
    if block.GameObject == null:
      raise System.Exception("Missing game object on block to be destroyed (${block.Indexes.x}, ${block.Indexes.y}, ${block.Indexes.z})")
    GameObject.Destroy(block.GameObject)
    newBlocks = blocks.Clone() as (Block, 3)
    newBlocks[blockLocation.x, blockLocation.y, blockLocation.z] = null
    Generate(newBlocks)
    return block