import UnityEngine
import System.Linq.Enumerable
import System.Collections.Generic

import Cubed

[RequireComponent(MeshFilter)]
[RequireComponent(MeshRenderer)]
[RequireComponent(MeshCollider)]
class BlockTerrainBehaviour(MonoBehaviour): 
	public chunkWidth = 10
	public chunkHeight = 10
	public chunkDepth = 10
	public blockWidth = 8f
	
	blockTerrain as BlockTerrain;
	
	def Start():
		blockTerrain = BlockTerrain(ChunkWidth: chunkWidth, ChunkHeight: chunkHeight, ChunkDepth: chunkDepth)
		# just create a full chunk for testing
		blocks = blockTerrain.GenerateFilledBlockGrid()
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
		
		meshCollider = GetComponent[of MeshCollider]()
		meshCollider.sharedMesh = meshFilter.mesh
	
	def RemoveBlock(blockLocation as Vector3i):
		pass
	
	def Update():
		pass
