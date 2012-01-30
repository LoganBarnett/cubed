using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Chunk : MonoBehaviour {
	public Vector3i gridPosition;
  	public Vector3i dimensionsInCubes;
	
	public CubedObjectBehaviour cubeObject;
	public float cubeSize = 10f;
	public Material blockMaterial;
	public CubeLegend cubeLegend;
	
	CubeMesh CalculateRenderableCube(Cube cube, ref int vertexCount, Cube[,,] cubes, Vector3i gridPosition) {
    	if (cube == null) return null;
	    cube.cubeSize = cubeSize;
	    cube.indexes = gridPosition;
	    cube.chunk = this;
	    var cubeMesh = cube.Calculate(cube.indexes, ref vertexCount, cubes, cubeLegend);
	    return cubeMesh;
	}
	
	CubeMesh[,,] GenerateRenderableCubes(Cube[,,] cubes) {
		var cubeMeshes = new CubeMesh[cubes.GetLength(0), cubes.GetLength(1), cubes.GetLength(2)];
		var vertexCount = 0;
		var begin = gridPosition * dimensionsInCubes;
		var end = begin + dimensionsInCubes;
		for (var cubeX = begin.x; cubeX < end.x; ++cubeX) {
			for (var cubeY = begin.y; cubeY < end.y; ++cubeY) {
				for (var cubeZ = begin.z; cubeZ < end.z; ++cubeZ) {
					var cube = cubes[cubeX, cubeY, cubeZ];
          			if (cube == null) continue;
          			var cubeGridPosition = new Vector3i(cubeX, cubeY, cubeZ);
					var cubeMesh = CalculateRenderableCube(cube, ref vertexCount, cubes, cubeGridPosition);
					cubeMeshes[cubeX, cubeY, cubeZ] = cubeMesh;
          			cubes[cubeX, cubeY, cubeZ] = cube;
				}
			}
		}
		return cubeMeshes;
	}
	
	public void Generate() {
		Generate(cubeObject.Cubes);
	}
	
	public void Generate(Cube[,,] cubesToGenerate) {
		var begin = gridPosition * dimensionsInCubes;
		var end = begin + dimensionsInCubes;
		
		for (var x = begin.x; x < end.x; ++x) {
      		for (var y = begin.y; y < end.y; ++y) {
        		for (var z = begin.z; z < end.z; ++z) {
          			if (cubesToGenerate[x,y,z] != null) cubesToGenerate[x,y,z].chunk = this;
				}
			}
		}

	    var cubeMeshes = GenerateRenderableCubes(cubesToGenerate);
	    var vertices = new List<Vector3>();
	    var triangles = new List<int>();
	    var uvs = new List<Vector2>();
		
		var collidableVertices = new List<Vector3>();
		var collidableTriangles = new List<int>();
	    //for block in cubes: // works well for matrixes
	
		for (var x = begin.x; x < end.x; ++x) {
	  		for (var y = begin.y; y < end.y; ++y) {
	    		for (var z = begin.z; z < end.z; ++z) {
		        	var cube = cubesToGenerate[x, y, z];
		        	if (cube == null) continue;
					var cubeMesh = cubeMeshes[x, y, z];
		        	vertices.AddRange(cubeMesh.RenderableVertices);
		        	triangles.AddRange(cubeMesh.RenderableTriangles);
		        	uvs.AddRange(cubeMesh.RenderableUvs);
					
					collidableVertices.AddRange(cubeMesh.CollidableVertices);
					collidableTriangles.AddRange(cubeMesh.CollidableTriangles);
				}
			}
		}
	
	    renderer.materials = new Material[] { blockMaterial };
	    
	    var meshFilter = GetComponent<MeshFilter>();
	    // sharedMesh is null during generation
	    // TODO: Fix this as the generator shows errors in the console when using mesh vs. sharedMesh
	    //mesh = (meshFilter.mesh if EditorApplication.isPlayingOrWillChangePlaymode else meshFilter.sharedMesh)
	    var mesh = meshFilter.mesh;
	    mesh.Clear();
	    mesh.vertices = vertices.ToArray();
	    mesh.triangles = triangles.ToArray();
	    mesh.uv = uvs.ToArray();
	    mesh.RecalculateNormals();
		
//		var meshCollider = GetComponent<MeshCollider>();
//		if (collidableVertices.Count > 0) {
//			if (meshCollider == null) meshCollider = gameObject.AddComponent<MeshCollider>();
//			var colliderMesh = new Mesh();
//			colliderMesh.vertices = collidableVertices.ToArray();
//			colliderMesh.triangles = collidableTriangles.ToArray();
//	    	meshCollider.sharedMesh = colliderMesh;
//	    	meshCollider.convex = false;
//			meshCollider.enabled = true;
//		} else {
//			if (meshCollider != null) meshCollider.enabled = false;
//		}
	}
}