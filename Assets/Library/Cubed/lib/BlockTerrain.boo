namespace Cubed

import UnityEngine
import System.Linq.Enumerable
import System.Collections.Generic

class BlockTerrain:
  [Property(ChunkWidth)]
  chunkWidth = 10
  [Property(ChunkHeight)]
  chunkHeight = 10
  [Property(ChunkDepth)]
  chunkDepth = 10
  
  [Property(BlockMaterial)]
  blockMaterial as Material
  
  [Property(BlockWidth)]
  blockWidth = 10f
  
  def GenerateFilledBlockGrid():
    grid = matrix(Block, ChunkWidth, ChunkHeight, ChunkDepth)
    for x in range(ChunkWidth):
      for y in range(ChunkHeight):
        for z in range(ChunkDepth):
          grid[x, y, z] = Block()
    return grid
    
  # TODO: pass an triangle count by ref so we know how far we are with triangles
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
    
  def GenerateChunks(chunksWide as int, chunksHigh as int):
    for x in range(chunksWide):
      for y in range(chunksHigh):
        GenerateChunk(x, y)
  
  def MakeChunk():
    gameObject = GameObject()
    gameObject.AddComponent(MeshFilter)
    gameObject.AddComponent(MeshCollider)
    gameObject.AddComponent(MeshRenderer)
    gameObject.name = "Chunk"
    return gameObject
    
  def GenerateChunk(x as int, y as int):
    blocks = GenerateFilledBlockGrid()
    renderableBlocks = GenerateRenderableBlocks(blocks)
    
    chunk = MakeChunk()
    chunk.transform.position = Vector3(x * chunkWidth * blockWidth, 0f, y * chunkDepth * blockWidth)
    vertices = List[of Vector3]()
    triangles = List[of int]()
    for block in renderableBlocks:
      vertices.AddRange(block.Vertices)
      triangles.AddRange(block.Triangles)
    
    meshRenderer = chunk.renderer #chunk.GetComponent of MeshRenderer()

    meshRenderer.materials = (blockMaterial,)
    
    meshFilter = chunk.GetComponent[of MeshFilter]()
    meshFilter.mesh.Clear()
    meshFilter.mesh.vertices = vertices.ToArray()
    meshFilter.mesh.triangles = triangles.ToArray()
#   meshFilter.mesh.uv = vertices.Select({v| Vector2(v.x, v.z)}).ToArray()
#   meshFilter.mesh.normals = mesh
    meshFilter.mesh.RecalculateNormals()
    
    meshCollider = chunk.GetComponent[of MeshCollider]()
    meshCollider.sharedMesh = meshFilter.mesh