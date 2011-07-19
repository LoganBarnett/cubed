import UnityEngine
import UnityEditor
import System.Linq.Enumerable
import System.Collections.Generic
import Cubed

[CustomEditor(CubedObjectBehaviour)]
class CubedModelEditor(Editor):
  #static def CreateModel():
  scrollY = 0f
  axisY = 0
  
  static def GenerateCubes(cubedObject as CubedObjectBehaviour):
    try:
      cubedObject.SendMessage("GenerateCubes", cubedObject)
    except e:
      # TODO: Put this back in when preprocessor directives are supported in Boo
      # Use UNITY_EDITOR
      #CubeGeneratorProgressEditor.End()
      Debug.LogError(e)

  static def PackTextures(cubedObject as CubedObjectBehaviour):
    textureLists = cubedObject.cubeDefinitions.Select({cd| cd.Textures})
    textures = List of Texture2D()
    for textureList in textureLists:
      textures.AddRange(textureList)
    packedTexture = Texture2D(1024, 1024)
    cubedObject.packedTexture = packedTexture
    cubedObject.textureAtlas = packedTexture.PackTextures(textures.ToArray(), 1)
    material = Material(cubedObject.material)
    material.mainTexture = packedTexture
    material.color = Color.white
    cubedObject.material = material
    Debug.Log("Packing ${textures.Count} Textures complete.")

  def OnInspectorGUI():
    if (GUILayout.Button("Bake Cubes")):
      GenerateCubes(target as CubedObjectBehaviour)

    if (GUILayout.Button("Pack Textures")):
      PackTextures(target as CubedObjectBehaviour)
    DrawDefaultInspector()
  
  def OnEnable():
    CubedEditorBackdrop.EnsureBackdropExists(target as CubedObjectBehaviour)
    cubedObject = target as CubedObjectBehaviour
    cubes = cubedObject.cubedObject.Cubes
    x = cubedObject.chunkDimensions.x * cubedObject.dimensionsInChunks.x
    y = cubedObject.chunkDimensions.y * cubedObject.dimensionsInChunks.y
    z = cubedObject.chunkDimensions.z * cubedObject.dimensionsInChunks.z
    cubes = matrix(Cube, x,y,z) unless cubes
    cubedObject.Generate(cubes)
    
  def OnDisable():
    CubedEditorBackdrop.DestroyBackdrop()
    GameObject.DestroyImmediate(GameObject.Find("CubedEditorPlaneCollision"))
    
  def OnSceneGUI():
    cubedObject = target as CubedObjectBehaviour
    HandleInput(cubedObject)
    DrawPaintingSelection(cubedObject)
    controlId = GUIUtility.GetControlID(FocusType.Passive)
    HandleUtility.AddDefaultControl(controlId) if Event.current.type == EventType.layout
    

  def DrawPaintingSelection(cubedObject as CubedObjectBehaviour):
    offset = cubedObject.transform.position
    DrawPlaneY(cubedObject, offset, axisY * cubedObject.cubeSize)
    DrawPlaneY(cubedObject, offset, cubedObject.cubeSize + (axisY * cubedObject.cubeSize))
    DrawConnectionY(cubedObject, offset)
    CreatePlaneCollisionY(cubedObject)
    
  def CreatePlaneCollisionY(cubedObject as CubedObjectBehaviour):
    collision = GameObject.Find("CubedEditorPlaneCollision")
    unless collision:
      collision = GameObject.CreatePrimitive(PrimitiveType.Cube)
      collision.name = "CubedEditorPlaneCollision"
      
    x = cubedObject.chunkDimensions.x * cubedObject.dimensionsInChunks.x
#    y = cubedObject.chunkDimensions.y * cubedObject.dimensionsInChunks.y
    z = cubedObject.chunkDimensions.z * cubedObject.dimensionsInChunks.z
    collision.transform.localScale = Vector3(x, 1f, z) * cubedObject.cubeSize
    offset = Vector3(x, cubedObject.cubeSize * axisY, z) / 2f
    collision.transform.position = cubedObject.transform.position + offset
    collision.renderer.enabled = false
    
  def DrawPlaneY(cubedObject as CubedObjectBehaviour, offset as Vector3, y as single):
    for x in range(0, (cubedObject.chunkDimensions.x * cubedObject.dimensionsInChunks.x) + 1):
      start = Vector3(x * cubedObject.cubeSize, y, 0f)
      end = Vector3(x * cubedObject.cubeSize, y, cubedObject.chunkDimensions.z * cubedObject.dimensionsInChunks.z * cubedObject.cubeSize)
      Debug.DrawLine(start + offset, end + offset, Color.yellow)

    for z in range(0, (cubedObject.chunkDimensions.z * cubedObject.dimensionsInChunks.z) + 1):
      start = Vector3(0f, y, z * cubedObject.cubeSize)
      end = Vector3(cubedObject.chunkDimensions.x * cubedObject.dimensionsInChunks.x * cubedObject.cubeSize, y, z * cubedObject.cubeSize)
      Debug.DrawLine(start + offset, end + offset, Color.yellow)
  
  def DrawConnectionY(cubedObject as CubedObjectBehaviour, offset as Vector3):
    for x in range(0, (cubedObject.chunkDimensions.x * cubedObject.dimensionsInChunks.x) + 1):
      for z in range(0, (cubedObject.chunkDimensions.z * cubedObject.dimensionsInChunks.z) + 1):
        start = Vector3(x * cubedObject.cubeSize, axisY * cubedObject.cubeSize, z * cubedObject.cubeSize)
        end = Vector3(x * cubedObject.cubeSize, cubedObject.cubeSize + (axisY * cubedObject.cubeSize), z * cubedObject.cubeSize)
        Debug.DrawLine(start + offset, end + offset, Color.yellow)

  def HandleInput(cubedObject as CubedObjectBehaviour):
    if Event.current.type == EventType.MouseDown and Event.current.button == 1: #and (Event.current.modifiers != EventModifiers.Alt and Event.current.modifiers == EventModifiers.Shift):
      Event.current.Use()
      #ChangeAxis()
      RemoveCubeAtMouseLocation(Event.current.mousePosition, cubedObject)
    elif Event.current.type == EventType.MouseDown and Event.current.button == 0:
      Event.current.Use()
      PlaceCubeAtMouseLocation(Event.current.mousePosition, cubedObject)
    elif Event.current.type == EventType.ScrollWheel:
      Event.current.Use()
      MoveAlongSelectionAxis(cubedObject, Event.current.delta)
  
  def MoveAlongSelectionAxis(cubedObject as CubedObjectBehaviour, delta as Vector2):
    scrollY -= delta.y
    axisY = scrollY
    axisY = 0 if axisY < 0
    maxY = (cubedObject.chunkDimensions.y * cubedObject.dimensionsInChunks.y) - 1
    axisY = maxY if axisY > maxY
    #Debug.Log(axisY)
  
  def PlaceCubeAtMouseLocation(position as Vector2, cubedObject as CubedObjectBehaviour):
    hits = Physics.RaycastAll(HandleUtility.GUIPointToWorldRay(position), Mathf.Infinity);
    hits = hits.OrderBy({hit| hit.distance}).ToArray();
    
    y = cubedObject.transform.position.y + (axisY * cubedObject.cubeSize)
    placement = Vector3(hits[0].point.x, y, hits[0].point.z)
    cubedObject.PlaceCubeAt(placement, Cube())
    
  def ChangeAxis():
    pass
    
  def RemoveCubeAtMouseLocation(position as Vector2, cubedObject as CubedObjectBehaviour):
    hits = Physics.RaycastAll(HandleUtility.GUIPointToWorldRay(position), Mathf.Infinity);
    hits = hits.OrderBy({hit| hit.distance}).ToArray();
    
    y = cubedObject.transform.position.y + (axisY * cubedObject.cubeSize)
    cubePosition = Vector3(hits[0].point.x, y, hits[0].point.z)
    cube = cubedObject.RemoveCubeAt(cubePosition)
    cube.Chunk.Generate(cube.Chunk.cubes)
    