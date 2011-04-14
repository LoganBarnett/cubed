namespace Cubed

import UnityEngine
import System.Linq.Enumerable
import System.Collections.Generic

class Chunk(MonoBehaviour):
  public blocks as (Block, 3)
  
  [Property(BlockWidth)]
  blockWidth = 10f
  
  [Property(BlockMaterial)]
  blockMaterial as Material
  
  def CalculateRenderableBlock(x as int, y as int, z as int, ref vertexCount as int, blocks as (Block, 3)):
    renderableBlock = RenderableBlock(BlockWidth: blockWidth)
    block = blocks[x,y,z]
    return renderableBlock if block == null
    
    gridPosition = Vector3i(x, y, z)
    renderableBlock.CalculateRenderableProperties(gridPosition, vertexCount, blocks)
    
    return renderableBlock
    
  def GenerateRenderableBlocks(blocks as (Block, 3)):
    renderableblocks = List[of RenderableBlock]()
    vertexCount = 0
    for x in range(len(blocks, 0)):
      for y in range(len(blocks, 1)):
        for z in range(len(blocks, 2)):
          renderableBlock = CalculateRenderableBlock(x, y, z, vertexCount, blocks)
          renderableblocks.Add(renderableBlock)
    return renderableblocks.ToArray()
  
  def Generate(blocks as (Block, 3)):
    renderableBlocks = GenerateRenderableBlocks(blocks)
    vertices = List[of Vector3]()
    triangles = List[of int]()
    uvs = List of Vector2()
    for block in renderableBlocks:
      vertices.AddRange(block.Vertices)
      triangles.AddRange(block.Triangles)
      uvs.AddRange(block.Uvs)

    renderer.materials = (blockMaterial,)
    
    meshFilter = GetComponent[of MeshFilter]()
    meshFilter.mesh.Clear()
    meshFilter.mesh.vertices = vertices.ToArray()
    meshFilter.mesh.triangles = triangles.ToArray()
    #uvs = CalculateUvs(vertices)
#   meshFilter.mesh.uv = vertices.Select({v| Vector2(v.x, v.z)}).ToArray()
    meshFilter.mesh.uv = uvs.ToArray()
#   meshFilter.mesh.normals = mesh
    meshFilter.mesh.RecalculateNormals()
    
    meshCollider = GetComponent[of MeshCollider]()
    meshCollider.sharedMesh = meshFilter.mesh
    
    GetComponent of Chunk().blocks = blocks
    
  def CalculateUvs(vertices as IEnumerable of Vector3):
    #planar coordinates
    return vertices.Select({v| Vector2(v.x, v.z)}).ToArray() 