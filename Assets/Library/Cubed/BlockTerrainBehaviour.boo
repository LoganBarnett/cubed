import UnityEngine
import System.Linq.Enumerable
import System.Collections.Generic

import Cubed

#[RequireComponent(MeshFilter)]
#[RequireComponent(MeshRenderer)]
#[RequireComponent(MeshCollider)]
class BlockTerrainBehaviour(MonoBehaviour): 
  public chunksHigh = 10
  public chunksWide = 10
  public chunkWidth = 10
  public chunkHeight = 10
  public chunkDepth = 10
  public blockWidth = 8f
  public blockMaterial as Material
  
  blockTerrain as BlockTerrain;
  
  def Start():
    blockTerrain = BlockTerrain(BlockWidth: blockWidth, ChunkWidth: chunkWidth, ChunkHeight: chunkHeight, ChunkDepth: chunkDepth, BlockMaterial: blockMaterial)
    # just create a full chunk for testing
    blockTerrain.GenerateChunks(chunksWide, chunksHigh)
  
  def RemoveBlock(blockLocation as Vector3i):
    pass
  
  def Update():
    pass
