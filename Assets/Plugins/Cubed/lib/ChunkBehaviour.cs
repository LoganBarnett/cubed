using UnityEngine;
using System.Collections;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class ChunkBehaviour : MonoBehaviour {
	public Chunk chunk;
	
	public void ApplyChunkSettings(Chunk chunk, CubedObjectBehaviour parent) {
		this.chunk = chunk;
		renderer.materials = new Material[] { chunk.blockMaterial };
		
		var mesh = new Mesh();
		mesh.Clear();
	    mesh.vertices = chunk.meshData.RenderableVertices.ToArray();
	    mesh.triangles = chunk.meshData.RenderableTriangles.ToArray();
	    mesh.uv = chunk.meshData.RenderableUvs.ToArray();
	    mesh.RecalculateNormals();
		
		var meshFilter = GetComponent<MeshFilter>();
	    // sharedMesh is null during generation
	    // TODO: Fix this as the generator shows errors in the console when using mesh vs. sharedMesh
	    //mesh = (meshFilter.mesh if EditorApplication.isPlayingOrWillChangePlaymode else meshFilter.sharedMesh)
		if(Application.isPlaying) meshFilter.mesh = mesh;
		else meshFilter.sharedMesh = mesh;
		
		if(parent.colliderType == ColliderType.MeshColliderPerChunk) {
			var colliderMesh = new Mesh();
			colliderMesh.vertices = chunk.meshData.CollidableVertices.ToArray();
			colliderMesh.triangles = chunk.meshData.CollidableTriangles.ToArray();
			var meshCollider = GetComponent<MeshCollider>();
			if(colliderMesh != null) {
				if(meshCollider == null) meshCollider = gameObject.AddComponent<MeshCollider>();
			   	meshCollider.sharedMesh = colliderMesh;
			   	meshCollider.convex = false;
				meshCollider.enabled = true;
			}
			else {
				if(meshCollider != null) meshCollider.enabled = false;
			}
		}
		transform.localPosition = (chunk.gridPosition * parent.chunkDimensions).ToVector3() * parent.cubeSize;
	}
}
