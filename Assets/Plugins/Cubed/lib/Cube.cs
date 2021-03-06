using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

[System.Serializable]
public class Cube {
	public int type = 0;
	public Vector3i indexes;
	public Chunk chunk;
	public GameObject gameObject;
	public LayerMask layer;
	public float cubeSize;
	
	bool generateCollider = true;
	static int[] baseTriangles = new int[] { 0, 1, 2, 1, 3, 2 };

	public CubeData ToCubeData() {
		return new CubeData { Type = type, Indexes = indexes };
	}
	
	public override string ToString() {
		return string.Format("{0},{1},{2},{3}", indexes.x, indexes.y, indexes.z, type);
	}

	public void CreateCollision(string cubeTag, ChunkBehaviour chunkBehaviour) {
		if (gameObject != null) {
			GameObject.Destroy(gameObject);
		}
		gameObject = new GameObject();
		gameObject.tag = cubeTag;
		gameObject.AddComponent<BoxCollider>();
		var collider = gameObject.collider as BoxCollider;
		collider.size = new Vector3(cubeSize, cubeSize, cubeSize);
		if(chunk != null) {
			var halfSize = collider.size / 2f;
			var offsetInChunk = (indexes - (chunk.gridPosition * chunk.dimensionsInCubes)).ToVector3() * cubeSize;
			var cubePosition = offsetInChunk + halfSize;
			gameObject.transform.parent = chunkBehaviour.transform;
			gameObject.transform.localPosition = cubePosition;
		}
//		(new Vector3(location.x * chunkDimensions.x, location.y * chunkDimensions.y, location.z * chunkDimensions.z) * cubeSize) + offset;
		
		gameObject.layer = layer;
		gameObject.AddComponent<CubeBehaviour>().cube = this;
		gameObject.name = GetCubeName(indexes);
	}

	public CubeMesh Calculate(ref int visualVertexCount, ref int collisionVertexCount, Cube[,,] cubes, CubeLegend cubeLegend, ColliderType colliderType, string cubeTag) {
		// TODO: Put this back in when preprocessor directives are supported in Boo
		// Use UNITY_EDITOR
		//CubeGeneratorProgressEditor.ReportCube(chunk.gridPosition, gridPosition) if chunk
		
		// TODO: Vector3i.zero
		// TODO: Cached cube position of the chunk
		var position = (indexes - (chunk.dimensionsInCubes * chunk.gridPosition)).ToVector3() * cubeSize;
		
		var meshData = new CubeMesh();
		
		if(!AdjacentCubeExistsInsideChunk(cubes, indexes.Down))  AddSide(Direction.Down,  position, ref visualVertexCount, cubeLegend, meshData);
		if(!AdjacentCubeExistsInsideChunk(cubes, indexes.Up))	  AddSide(Direction.Up,    position, ref visualVertexCount, cubeLegend, meshData);
		if(!AdjacentCubeExistsInsideChunk(cubes, indexes.Right)) AddSide(Direction.Right, position, ref visualVertexCount, cubeLegend, meshData);
		if(!AdjacentCubeExistsInsideChunk(cubes, indexes.Left))  AddSide(Direction.Left,  position, ref visualVertexCount, cubeLegend, meshData);
		if(!AdjacentCubeExistsInsideChunk(cubes, indexes.Front)) AddSide(Direction.Front, position, ref visualVertexCount, cubeLegend, meshData);
		if(!AdjacentCubeExistsInsideChunk(cubes, indexes.Back))  AddSide(Direction.Back,  position, ref visualVertexCount, cubeLegend, meshData);
		
		if (cubeLegend.cubeDefinitions[type].hasCollision) {
			if(colliderType == ColliderType.MeshColliderPerChunk) {
				if(!AdjacentCubeExistsInsideChunkWithCollision(cubes, cubeLegend, indexes.Down))  AddCollisionSide(Direction.Down,  position, ref collisionVertexCount, cubeLegend, meshData);
				if(!AdjacentCubeExistsInsideChunkWithCollision(cubes, cubeLegend, indexes.Up))	   AddCollisionSide(Direction.Up,    position, ref collisionVertexCount, cubeLegend, meshData);
				if(!AdjacentCubeExistsInsideChunkWithCollision(cubes, cubeLegend, indexes.Right)) AddCollisionSide(Direction.Right, position, ref collisionVertexCount, cubeLegend, meshData);
				if(!AdjacentCubeExistsInsideChunkWithCollision(cubes, cubeLegend, indexes.Left))  AddCollisionSide(Direction.Left,  position, ref collisionVertexCount, cubeLegend, meshData);
				if(!AdjacentCubeExistsInsideChunkWithCollision(cubes, cubeLegend, indexes.Front)) AddCollisionSide(Direction.Front, position, ref collisionVertexCount, cubeLegend, meshData);
				if(!AdjacentCubeExistsInsideChunkWithCollision(cubes, cubeLegend, indexes.Back))  AddCollisionSide(Direction.Back,  position, ref collisionVertexCount, cubeLegend, meshData);
			}
			else if(colliderType == ColliderType.BoxColliderPerCube) {
				// TODO: Defer this until the game objects are being created for async compatibility
//				if(generateCollider) CreateCollision(cubeTag);
			}
		}
		return meshData;
	}

	public string GetCubeName(Vector3i gridPosition) {
		return string.Format("Cube Collider ({0}, {1}, {2})", gridPosition.x, gridPosition.y, gridPosition.z);
	}

	public CubeMesh AddSide(Direction side, Vector3 position, ref int vertexCount, CubeLegend cubeLegend, CubeMesh meshData) {
		var vertices = CalculateSideVertices(position, side);
		meshData.RenderableVertices.AddRange(vertices);
		meshData.RenderableUvs.AddRange(cubeLegend.UvsFor(type, side));
		AddTriangles(cubeLegend, meshData, vertexCount);
		vertexCount += 4;
		return meshData;
	}
	
	public CubeMesh AddCollisionSide(Direction side, Vector3 position, ref int vertexCount, CubeLegend cubeLegend, CubeMesh meshData) {
		var vertices = CalculateSideVertices(position, side);
		meshData.CollidableVertices.AddRange(vertices);
		AddCollisionTriangles(meshData, vertexCount);
		generateCollider = true;
		vertexCount += 4;
		return meshData;
	}
	
	List<Vector3> CalculateSideVertices(Vector3 position, Direction side) {
		var vertices = new List<Vector3>();
		switch (side) {
		case Direction.Down:
			vertices.Add(new Vector3(position.x + cubeSize, position.y, position.z));
			vertices.Add(new Vector3(position.x + cubeSize, position.y, position.z + cubeSize));
			vertices.Add(position);
			vertices.Add(new Vector3(position.x, position.y, position.z + cubeSize));
			break;
		case Direction.Up:
			vertices.Add(new Vector3(position.x, position.y + cubeSize, position.z));
			vertices.Add(new Vector3(position.x, position.y + cubeSize, position.z + cubeSize));
			vertices.Add(new Vector3(position.x + cubeSize, position.y + cubeSize, position.z));
			vertices.Add(new Vector3(position.x + cubeSize, position.y + cubeSize, position.z + cubeSize));
			break;
		case Direction.Right:
			vertices.Add(new Vector3(position.x + cubeSize, position.y, position.z));
			vertices.Add(new Vector3(position.x + cubeSize, position.y + cubeSize, position.z));
			vertices.Add(new Vector3(position.x + cubeSize, position.y, position.z + cubeSize));
			vertices.Add(new Vector3(position.x + cubeSize, position.y + cubeSize, position.z + cubeSize));
			break;
		case Direction.Left:
			vertices.Add(new Vector3(position.x, position.y, position.z + cubeSize));
			vertices.Add(new Vector3(position.x, position.y + cubeSize, position.z + cubeSize));
			vertices.Add(new Vector3(position.x, position.y, position.z));
			vertices.Add(new Vector3(position.x, position.y + cubeSize, position.z));
			break;
		case Direction.Front:
			vertices.Add(new Vector3(position.x + cubeSize, position.y, position.z + cubeSize));
			vertices.Add(new Vector3(position.x + cubeSize, position.y + cubeSize, position.z + cubeSize));
			vertices.Add(new Vector3(position.x, position.y, position.z + cubeSize));
			vertices.Add(new Vector3(position.x, position.y + cubeSize, position.z + cubeSize));
			break;
		case Direction.Back:
			vertices.Add(new Vector3(position.x, position.y, position.z));
			vertices.Add(new Vector3(position.x, position.y + cubeSize, position.z));
			vertices.Add(new Vector3(position.x + cubeSize, position.y, position.z));
			vertices.Add(new Vector3(position.x + cubeSize, position.y + cubeSize, position.z));
			break;
		}
		return vertices;
	}

	void AddTriangles(CubeLegend cubeLegend, CubeMesh meshData, int vertexCount) {
		var newTriangles = baseTriangles.Select(i => i + vertexCount);
		meshData.RenderableTriangles.AddRange(newTriangles);
	}
	
	void AddCollisionTriangles(CubeMesh meshData, int vertexCount) {
		var newTriangles = baseTriangles.Select(i => i + vertexCount);
		meshData.CollidableTriangles.AddRange(newTriangles);
	}

	public Cube GetCubeInChunk(Cube[,,] cubes, Vector3i position) {
		try {
			var cube = cubes[position.x, position.y, position.z];
			if (cube == null)
				return null;
			if (cube.chunk == null)
				return null;
			if (cube.chunk != null && cube.chunk.gridPosition != chunk.gridPosition)
				return null;
			return cube;
		} catch (System.IndexOutOfRangeException) {
			return null;
		}
	}

	public bool AdjacentCubeExistsInsideChunk(Cube[,,] cubes, Vector3i adjacentPosition) {
		return GetCubeInChunk(cubes, adjacentPosition) != null;
	}
	
	public bool AdjacentCubeExistsInsideChunkWithCollision(Cube[,,] cubes, CubeLegend legend, Vector3i adjacentPosition) {
		var cube = GetCubeInChunk(cubes, adjacentPosition);
		return cube != null && legend.cubeDefinitions[cube.type].hasCollision;
	}
	
	public Vector3 WorldPosition {
		get {
			return chunk.GetWorldPositionOf(indexes);
		}
	}
	
//	bool AllAdjacentCubesExist(Cube[,,] cubes) {
//		return  GetCube(cubes, indexes.Down) != null &&
//				GetCube(cubes, indexes.Up) != null &&
//				GetCube(cubes, indexes.Right) != null &&
//				GetCube(cubes, indexes.Left) != null &&
//				GetCube(cubes, indexes.Front) != null &&
//				GetCube(cubes, indexes.Back) != null;
//	}
	
	Cube GetCube(Cube[,,] cubes, Vector3i position) {
		try {
			var cube = cubes[position.x, position.y, position.z];
			if(cube == null) return null;
			return cube;
		} catch (System.IndexOutOfRangeException) {
			return null;
		}
	}
}
