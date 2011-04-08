import UnityEngine
import System.Linq.Enumerable
import System.Collections.Generic

import Cubed

[RequireComponent(MeshFilter)]
[RequireComponent(MeshRenderer)]
class BlockTerrainBehaviour(MonoBehaviour): 
	public chunkWidth = 10f;
	public blockWidth = 10f;
	
	blockTerrain as BlockTerrain;
	
	def Start():
		blockTerrain = BlockTerrain(ChunkWidth: chunkWidth);
		blocks = blockTerrain.GenerateBlockGrid()
		renderableBlocks = blockTerrain.GenerateRenderableBlocks(blocks)
		
		vertices = List[of Vector3]()
		triangles = List[of int]()
		for block in renderableBlocks:
			vertices.AddRange(block.Vertices)
			triangles.AddRange(block.Triangles)
		
		meshFilter = GetComponent[of MeshFilter]()
		meshFilter.mesh.Clear()
		meshFilter.mesh.vertices = vertices.ToArray()
		meshFilter.mesh.triangles = triangles.ToArray()
#		meshFilter.mesh.uv = vertices.Select({v| Vector2(v.x, v.z)}).ToArray()
#		meshFilter.mesh.normals = mesh
		meshFilter.mesh.RecalculateNormals()
	
	def Update():
		pass
