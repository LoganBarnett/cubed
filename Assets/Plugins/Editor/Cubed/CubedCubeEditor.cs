using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Collections;
using System.Linq;

[CustomEditor(typeof(CubeDefinition))]
public class CubedCubeEditor : Editor {
	[MenuItem("Assets/Create/Cube Definition")]
	public static void CreateCubeDefinitionAsset() {
		AssetDatabase.CreateAsset(ScriptableObject.CreateInstance<CubeDefinition>(), "Assets/Cube Definition.asset");
	}
	
	public override void OnInspectorGUI() {
		base.OnInspectorGUI();
		var rect = new Rect(0f, 300f, 300f, 300f);
//		EditorGUIUtility.RenderGameViewCameras(rect, rect, false, false);
	}
	
//	public override bool HasPreviewGUI() {
//		return true;
//	}
	
	void OnPreviewGUI(Rect rect, GUIStyle background) {
		Debug.Log("preview gui");
//		EditorGUIUtility.RenderGameViewCameras(r,r,false, false);
//		GL.Begin(GL.TRIANGLES); {
//			GL.Vertex3(0.5f, 0.5f, 0.5f);
//			GL.Vertex3(0.25f, 0.25f, 0.5f);
//			GL.Vertex3(0.5f, 0.25f, 0.5f);
//			GL.Viewport(rect);
//		} GL.End();
	}
}