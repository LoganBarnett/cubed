import UnityEngine
import UnityEditor
import System.Linq.Enumerable
import System.Collections.Generic

#[CustomEditor(CubedObjectBehaviour)]
# TODO: Merge into main editor
class CubeGeneratorEditor(Editor):
#  [MenuItem("Cubed/Generate Cubes")]
#  static def GenerateCubes(): 
#    for cubedObjectGameObject in Selection.gameObjects:
#      cubedObject = cubedObjectGameObject.GetComponent of CubedObjectBehaviour()
#      GenerateCubes(cubedObject)
  
#  [MenuItem("Cubed/Pack Textures")]
#  static def PackTextures(): 
#    for cubeManagerGameObject in Selection.gameObjects:
#      # TODO: Move to cube manager/terrain
#      cubedObject = cubeManagerGameObject.GetComponent of CubedObjectBehaviour()
#      PackTextures(cubedObject)
      
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
    
  