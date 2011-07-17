import UnityEngine

class CubedEditorBackdrop:
  static def EnsureBackdropExists(target as CubedObjectBehaviour):
    backdrop = GameObject.Find("Backdrop")
    return if backdrop
    
    backdrop = GameObject()
    backdrop.name = "Backdrop"
    backdrop.hideFlags = HideFlags.NotEditable & HideFlags.HideInInspector
    backdrop.transform.position = target.transform.position
    CreatePlane(backdrop, Color.red,   Vector3.zero,        Vector3.zero)
    CreatePlane(backdrop, Color.blue,  Vector3(90, 0,   0), Vector3( 0f, 1f, -1f))
    CreatePlane(backdrop, Color.green, Vector3( 0, 0, -90), Vector3(-1f, 1f,  0f))
    
  static def DestroyBackdrop():
    GameObject.DestroyImmediate(GameObject.Find("Backdrop"))
  
  static def CreatePlane(backdrop as GameObject, color as Color, euler as Vector3, offset as Vector3):
    plane = GameObject.CreatePrimitive(PrimitiveType.Plane)
    plane.transform.parent = backdrop.transform
    plane.transform.localScale = Vector3.one * 0.8f
    plane.transform.localPosition = offset * 4f + Vector3(4f, 0f, 4f)
    plane.transform.Rotate(euler.x, euler.y, euler.z)
    material = Material(Shader.Find("VertexLit"))
    material.color = Color.black;
    material.SetColor("_Emission", color)
    material.color = Color(0.5f, 0, 0)
    plane.renderer.material = material
    return plane