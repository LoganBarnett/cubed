namespace Cubed
import UnityEngine

class BarrierGenerator:
  [Property(CubeWidth)]
  blockWidth = 10f
  
  [Property(ChunkWidth)]
  chunkWidth = 10
  [Property(ChunkHeight)]
  chunkHeight = 10
  [Property(ChunkDepth)]
  chunkDepth = 10
  
  [Property(ShowFloor)]
  showFloor = true
  [Property(ShowWalls)]
  showWalls = true
  
  [Property(FloorMaterial)]
  floorMaterial as Material
  [Property(WallMaterial)]
  wallMaterial as Material
  
  def MakeBarrier():
    return GameObject.CreatePrimitive(PrimitiveType.Cube);

  def GenerateBarriers(chunksWide as int, chunksDeep as int):
    GenerateGroundBarriers(chunksWide, chunksDeep)
    GenerateSideBarriers(chunksWide, chunksDeep)
  
  def GenerateSideBarriers(chunksWide as int, chunksDeep as int):
    # south side
    for chunkX in range(chunksWide):
      barrier = MakeBarrier()
      barrier.name = "Wall"
      barrier.renderer.enabled = showWalls
      barrier.renderer.material = wallMaterial
      barrier.transform.localScale = Vector3(chunkWidth * blockWidth, blockWidth * chunkHeight * 2f, blockWidth)
      x = (chunkX * chunkWidth * blockWidth) + ((chunkWidth * blockWidth) / 2f)
      z = -blockWidth / 2f #chunkZ * chunkDepth * blockWidth + ((chunkDepth * blockWidth) / 2f)
      y = blockWidth * chunkHeight
      barrier.transform.position = Vector3(x, y, z)
    
    # north side
    for chunkX in range(chunksWide):
      barrier = MakeBarrier()
      barrier.name = "Wall"
      barrier.renderer.enabled = showWalls
      barrier.renderer.material = wallMaterial
      barrier.transform.localScale = Vector3(chunkWidth * blockWidth, blockWidth * chunkHeight * 2f, blockWidth)
      x = (chunkX * chunkWidth * blockWidth) + ((chunkWidth * blockWidth) / 2f)
      z = (chunkDepth * blockWidth * chunksWide) + (blockWidth / 2f)
      y = blockWidth * chunkHeight
      barrier.transform.position = Vector3(x, y, z)
    
    # west side
    for chunkZ in range(chunksDeep):
      barrier = MakeBarrier()
      barrier.name = "Wall"
      barrier.renderer.enabled = showWalls
      barrier.renderer.material = wallMaterial
      barrier.transform.localScale = Vector3(blockWidth, blockWidth * chunkHeight * 2f, chunkDepth * blockWidth)
      x = -blockWidth / 2f
      z = (chunkDepth * blockWidth * chunkZ) + (chunkDepth * blockWidth / 2f)
      y = blockWidth * chunkHeight
      barrier.transform.position = Vector3(x, y, z)
    
    # west side
    for chunkZ in range(chunksDeep):
      barrier = MakeBarrier()
      barrier.name = "Wall"
      barrier.renderer.enabled = showWalls
      barrier.renderer.material = wallMaterial
      barrier.transform.localScale = Vector3(blockWidth, blockWidth * chunkHeight * 2f, chunkDepth * blockWidth)
      x = (chunkDepth * blockWidth * chunksWide) + (blockWidth / 2f)
      z = (chunkDepth * blockWidth * chunkZ) + (chunkDepth * blockWidth / 2f)
      y = blockWidth * chunkHeight
      barrier.transform.position = Vector3(x, y, z)
      
  
  def GenerateGroundBarriers(chunksWide as int, chunksDeep as int):
    for chunkX in range(chunksWide):
      for chunkZ in range(chunksDeep):
        barrier = MakeBarrier()
        barrier.name = "Ground"
        barrier.renderer.enabled = showFloor
        barrier.renderer.material = floorMaterial
        barrier.transform.localScale = Vector3(chunkWidth * blockWidth, blockWidth, chunkDepth * blockWidth)
        x = (chunkX * chunkWidth * blockWidth) + ((chunkWidth * blockWidth) / 2f)
        z = chunkZ * chunkDepth * blockWidth + ((chunkDepth * blockWidth) / 2f)
        #y = -(chunkHeight * blockWidth / 4f)
        y = -blockWidth / 2f
        barrier.transform.position = Vector3(x, y, z)