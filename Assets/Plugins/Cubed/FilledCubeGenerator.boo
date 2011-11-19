#import UnityEngine
#
#[ExecuteInEditMode]
#class FilledCubeGenerator(MonoBehaviour):
#  public dimensionsInChunks as Vector3i
#  public chunkDimensions as Vector3i
#  
#  def GenerateCubes(cubedObject as CubedObjectBehaviour):
#    cubedObject.dimensionsInChunks = dimensionsInChunks
#    cubedObject.chunkDimensions = chunkDimensions
#    
#    totalCubes = dimensionsInChunks * chunkDimensions
#    cubes = matrix(Cube, totalCubes.x, totalCubes.y, totalCubes.z)
#    for x in range(totalCubes.x):
#      for y in range(totalCubes.y):
#        for z in range(totalCubes.z):
#          cube = Cube()
#          cube.indexes = Vector3i(x,y,z)
#          cubes[x,y,z] = cube
#     
#    cubedObject.Generate(cubes)