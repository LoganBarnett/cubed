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
  
  [Property(FloorMaterial)]
  floorMaterial as Material
  
  [Property(BlockWidth)]
  blockWidth = 10f
  
  def GenerateFilledBlockGrid():
    grid = matrix(Block, ChunkWidth, ChunkHeight, ChunkDepth)
    for x in range(ChunkWidth):
      for y in range(ChunkHeight):
        for z in range(ChunkDepth):
          grid[x, y, z] = Block()
    return grid
        
  def GenerateChunks(chunksWide as int, chunksHigh as int):
    for x in range(chunksWide):
      for y in range(chunksHigh):
        GenerateChunk(x, y, null)
  
  def MakeChunk():
    gameObject = GameObject()
    gameObject.AddComponent(MeshFilter)
    gameObject.AddComponent(MeshCollider)
    gameObject.AddComponent(MeshRenderer)
    chunkComponent = gameObject.AddComponent(Chunk)
    chunkComponent.BlockWidth = blockWidth
    chunkComponent.BlockMaterial = blockMaterial
    gameObject.name = "Chunk"
    return gameObject
    
  def GenerateChunk(x as int, y as int, blocks as (Block, 3)):
    blocks = GenerateFilledBlockGrid() if blocks == null
    
    chunk = MakeChunk()
    chunk.transform.position = Vector3(x * chunkWidth * blockWidth, 0f, y * chunkDepth * blockWidth)
    chunk.GetComponent of Chunk().Generate(blocks)
  
  def MakeBarrier():
    return GameObject.CreatePrimitive(PrimitiveType.Cube);
    
  def GenerateBarriers(chunksWide as int, chunksHigh as int):
    GenerateGroundBarriers(chunksWide, chunksHigh)
    
  def GenerateGroundBarriers(chunksWide as int, chunksHigh as int):
    for chunkX in range(chunksWide):
      for chunkZ in range(chunksHigh):
        barrier = MakeBarrier()
        barrier.renderer.material = floorMaterial
        barrier.transform.localScale = Vector3(chunkWidth * blockWidth, blockWidth, chunkDepth * blockWidth)
        x = (chunkX * chunkWidth * blockWidth) + ((chunkWidth * blockWidth) / 2f)
        z = chunkZ * chunkDepth * blockWidth + ((chunkDepth * blockWidth) / 2f)
        #y = -(chunkHeight * blockWidth / 4f)
        y = -blockWidth / 2f
        barrier.transform.position = Vector3(x, y, z)