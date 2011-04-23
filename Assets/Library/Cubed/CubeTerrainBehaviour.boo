import UnityEngine
import System.Linq.Enumerable
#import System.Collections.Generic

import Cubed

#[RequireComponent(MeshFilter)]
#[RequireComponent(MeshRenderer)]
#[RequireComponent(MeshCollider)]
class CubeTerrainBehaviour(MonoBehaviour): 
  public chunksHigh = 10
  public chunksWide = 10
  public chunkWidth = 10
  public chunkHeight = 10
  public chunkDepth = 10
  public blockWidth = 8f
  public blockMaterial as Material
  public wallMaterial as Material
  public floorMaterial as Material
  public showWalls = true
  public showFloor = true
  
  cubeTerrain as CubeTerrain;
  
  def Start():
    # TODO: This is getting painful
    # Make chunk height/depth/width into WorldDimensions property
    cubeTerrain = CubeTerrain(CubeWidth: blockWidth, ChunkWidth: chunkWidth, ChunkHeight: chunkHeight, ChunkDepth: chunkDepth, CubeMaterial: blockMaterial)
    # just create a full chunk for testing
    cubeTerrain.GenerateChunks(chunksWide, chunksHigh)
    #cubeTerrain.GenerateBarriers(chunksWide, chunksHigh)
  
  def GetCubeAt(ray as Ray, distance as single):
    return cubeTerrain.GetCubeAt(ray, distance)
  
  def RemoveCubeAt(ray as Ray, digDistance as single):
    cube = cubeTerrain.GetCubeAt(ray, digDistance)
    return null if cube == null
    return cube.Chunk.RemoveCube(cube.Indexes)
  
  def PlaceCubeOnChunk(aimingRay as Ray, placeDistance as single, cube as GameObject):
    hit = RaycastHit()
    return false unless Physics.Raycast(aimingRay, hit, placeDistance)
    if hit.collider.CompareTag("cubed_cube"):
      cubePlacement = cubeTerrain.GetCubePlacement(aimingRay, placeDistance)
      cubeTerrain.PlaceCube(cubePlacement, cube)
      return true
    return false
