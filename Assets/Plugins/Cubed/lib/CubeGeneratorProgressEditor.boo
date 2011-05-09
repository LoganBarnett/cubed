import UnityEditor
import UnityEngine

class CubeGeneratorProgressEditor(EditorWindow):
  static window as CubeGeneratorProgressEditor
  static hide = false
  static currentObjectCount = 0
  static totalObjectCount = 0
  static currentObjectMessage = ""
  
  static def Start(cubedObjectDimensions as Vector3i, chunkDimensions as Vector3i):
    return if EditorApplication.isPlayingOrWillChangePlaymode
    numberOfChunks = cubedObjectDimensions.x * cubedObjectDimensions.y # no z yet
    numberOfCubes = chunkDimensions.x * chunkDimensions.y * chunkDimensions.z * numberOfChunks
    totalObjectCount = numberOfChunks + numberOfCubes
    #window = GetWindow(CubeGeneratorProgressEditor)
    #window.Show()
    
  static def End():
    return if EditorApplication.isPlayingOrWillChangePlaymode
    hide = true
    Display()
  
  static def ReportChunk(location as Vector3i):
    return if EditorApplication.isPlayingOrWillChangePlaymode
    currentObjectCount += 1
    currentObjectMessage = "Chunk (${location.x}, ${location.y})"
    Display()
    
  static def ReportCube(chunkLocation as Vector3i, cubeLocation as Vector3i):
    return if EditorApplication.isPlayingOrWillChangePlaymode
    currentObjectCount += 1
    currentObjectMessage = "Chunk (${chunkLocation.x}, ${chunkLocation.y}) Cube (${cubeLocation.x}, ${cubeLocation.y}, ${cubeLocation.z})"
    Display()
    
  static def Display():
    if hide:
      EditorUtility.ClearProgressBar()
    else:
      titleText = "Generating Cubes (${currentObjectCount} / ${totalObjectCount})"
      EditorUtility.DisplayProgressBar(titleText, currentObjectMessage, cast(single, currentObjectCount) / cast(single, totalObjectCount))