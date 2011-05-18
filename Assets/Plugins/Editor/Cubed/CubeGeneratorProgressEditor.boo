#import UnityEditor

#class CubeGeneratorProgressEditor(EditorWindow):
#  static window as CubeGeneratorProgressEditor
#  static hide = false
#  static currentObjectCount = 0
#  static totalObjectCount = 0
#  static currentObjectMessage = ""
#  static timeStarted = 0f
#  
#  static def Start(cubedObjectDimensions as Vector3i, chunkDimensions as Vector3i):
#    return if EditorApplication.isPlayingOrWillChangePlaymode
#    numberOfChunks = cubedObjectDimensions.x * cubedObjectDimensions.y * cubedObjectDimensions.z
#    numberOfCubes = chunkDimensions.x * chunkDimensions.y * chunkDimensions.z * numberOfChunks
#    totalObjectCount = numberOfChunks + numberOfCubes
#    timeStarted = EditorApplication.timeSinceStartup
#    
#  static def End():
#    return if EditorApplication.isPlayingOrWillChangePlaymode
#    hide = true
#    Display()
#  
#  static def ReportChunk(location as Vector3i):
#    return if EditorApplication.isPlayingOrWillChangePlaymode 
#    currentObjectCount += 1
#    currentObjectMessage = "Chunk (${location.x}, ${location.y}, ${location.z})"
#    Display()
#    
#  static def ReportCube(chunkLocation as Vector3i, cubeLocation as Vector3i):
#    return if EditorApplication.isPlayingOrWillChangePlaymode or chunkLocation == null or cubeLocation == null
#    currentObjectCount += 1
#    currentObjectMessage = "Chunk (${chunkLocation.x}, ${chunkLocation.y}, ${chunkLocation.z}) Cube (${cubeLocation.x}, ${cubeLocation.y}, ${cubeLocation.z})"
#    Display()
#
#    
#  static def Display():
#    if hide:
#      EditorUtility.ClearProgressBar()
#    else:
#      return if timeStarted + 0.5f > EditorApplication.timeSinceStartup
#      titleText = "Generating Cubes (${currentObjectCount} / ${totalObjectCount})"
#      EditorUtility.DisplayCancelableProgressBar(titleText, currentObjectMessage, cast(single, currentObjectCount) / cast(single, totalObjectCount))
