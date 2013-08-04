using UnityEngine;
using System.Collections.Generic;

[System.Serializable]
public class CubeMesh {
	public List<int> RenderableTriangles { get; set; }
	public List<Vector3> RenderableVertices { get; set; }
	public List<Vector2> RenderableUvs { get; set; }
	
	public List<int> CollidableTriangles { get; set; }
	public List<Vector3> CollidableVertices { get; set; }
	
	public CubeMesh() {
		RenderableVertices = new List<Vector3>();
		RenderableUvs = new List<Vector2>();
		RenderableTriangles = new List<int>();
		
		CollidableVertices = new List<Vector3>();
		CollidableTriangles = new List<int>();
	}
}