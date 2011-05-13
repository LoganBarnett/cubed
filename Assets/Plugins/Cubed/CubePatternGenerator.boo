import Cubed

class CubePatternGenerator:
  static def GenerateFilledCubeGrid(cubedObject as CubedObjectBehaviour):
    totalX = cubedObject.chunkDimensions.x * cubedObject.dimensionsInChunks.x
    totalY = cubedObject.chunkDimensions.y * cubedObject.dimensionsInChunks.y
    totalZ = cubedObject.chunkDimensions.z * cubedObject.dimensionsInChunks.z
    grid = matrix(Cube, totalX, totalY, totalZ)
    for x in range(totalX):
      for y in range(totalY):
        for z in range(totalZ):
          cube = Cube()
          cube.indexes = Vector3i(x,y,z)
          grid[x, y, z] = cube
    return grid

  static def GenerateHalfFilledCubeGrid(cubedObject as CubedObjectBehaviour):
    totalX = cubedObject.chunkDimensions.x * cubedObject.dimensionsInChunks.x
    totalY = cubedObject.chunkDimensions.y * cubedObject.dimensionsInChunks.y
    totalZ = cubedObject.chunkDimensions.z * cubedObject.dimensionsInChunks.z
    grid = matrix(Cube, totalX, totalY, totalZ)
    for x in range(totalX):
      for y in range(totalY):
        continue if y > (totalY - 1) / 2 
        for z in range(totalZ):
          cube = Cube()
          cube.Type = x % 2
          cube.indexes = Vector3i(x,y,z)
          grid[x, y, z] = cube
    return grid
    
  static def GenerateVertexStressTestGrid(cubedObject as CubedObjectBehaviour):
      totalX = cubedObject.chunkDimensions.x * cubedObject.dimensionsInChunks.x
      totalY = cubedObject.chunkDimensions.y * cubedObject.dimensionsInChunks.y
      totalZ = cubedObject.chunkDimensions.z * cubedObject.dimensionsInChunks.z
      grid = matrix(Cube, totalX, totalY, totalZ) 
      for x in range(totalX):
        for y in range(totalY):
          for z in range(totalZ):
            continue if (x % 2 == 1 and z % 2 == 1 and y % 2 == 0) or (x % 2 == 0 and z % 2 == 1 and y % 2 == 1) or (x % 2 == 1 and z % 2 == 0 and y % 2 == 1) #or (x % 2 == 1 and z % 2 == 1 and y % 2 == 0)
            cube = Cube()
            cube.Type = x % 2
            cube.indexes = Vector3i(x,y,z)
            grid[x, y, z] = cube
      return grid