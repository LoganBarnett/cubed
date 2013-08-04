using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[System.Serializable]
public class Chunk {
	public Vector3i gridPosition;
  	public Vector3i dimensionsInCubes;
	
	public CubedObjectBehaviour cubeObject;
	public float cubeSize = 10f;
	public Material blockMaterial;
	public CubeLegend cubeLegend;
	public CubeMesh meshData;
	
	public void Generate() {
		Generate(cubeObject.Cubes);
	}
	
	public void Generate(Cube[,,] cubesToGenerate) {
		var begin = gridPosition * dimensionsInCubes;
		var end = begin + dimensionsInCubes;
		
		// TODO: We should be able to force this upon cube addition.
		for (var x = begin.x; x < end.x; ++x) {
      		for (var y = begin.y; y < end.y; ++y) {
        		for (var z = begin.z; z < end.z; ++z) {
#if DEBUG
					try {
#endif
						if(cubesToGenerate[x,y,z] != null) cubesToGenerate[x,y,z].chunk = this;
#if DEBUG
					}
					catch(System.IndexOutOfRangeException) {
						var location = new Vector3i(x, y, z);
						var message = string.Format(
							"Couldn't find cube at {0}. Perhaps the cube array is out of sync? Dimensions: {0}",
							location,
							cubeObject.TotalDimensions
						);
						Debug.LogError(message);
						throw;
					}
#endif
				}
			}
		}

	    var cubeMeshes = GenerateRenderableCubes(cubesToGenerate);
	    meshData = new CubeMesh();
	    //for block in cubes: // works well for matrixes
	
		for (var x = begin.x; x < end.x; ++x) {
	  		for (var y = begin.y; y < end.y; ++y) {
	    		for (var z = begin.z; z < end.z; ++z) {
		        	var cube = cubesToGenerate[x, y, z];
		        	if (cube == null) continue;
					cube.chunk = this;
					var cubeMesh = cubeMeshes[x, y, z];
					// TODO: Make a CubeMesh.AddFrom(CubeMesh)
		        	meshData.RenderableVertices.AddRange(cubeMesh.RenderableVertices);
		        	meshData.RenderableTriangles.AddRange(cubeMesh.RenderableTriangles);
		        	meshData.RenderableUvs.AddRange(cubeMesh.RenderableUvs);
					
					meshData.CollidableVertices.AddRange(cubeMesh.CollidableVertices);
					meshData.CollidableTriangles.AddRange(cubeMesh.CollidableTriangles);
				}
			}
		}
	}
	
	public Vector3 GetWorldPositionOf(Vector3i indexes) {
		return cubeObject.GetWorldPositionOf(indexes);
	}
	
	CubeMesh CalculateRenderableCube(Cube cube, ref int visualVertexCount, ref int collisionVertexCount, Cube[,,] cubes, Vector3i gridPosition) {
    	if (cube == null) return null;
	    cube.cubeSize = cubeSize;
		
	    cube.indexes = gridPosition;
	    cube.chunk = this;
	    var cubeMesh = cube.Calculate(ref visualVertexCount, ref collisionVertexCount,cubes, cubeLegend, cubeObject.colliderType, cubeObject.cubeTag);
	    return cubeMesh;
	}
	
	CubeMesh[,,] GenerateRenderableCubes(Cube[,,] cubes) {
		var cubeMeshes = new CubeMesh[cubes.GetLength(0), cubes.GetLength(1), cubes.GetLength(2)];
		var visualVertexCount = 0;
		var collisionVertexCount = 0;
		var begin = gridPosition * dimensionsInCubes;
		var end = begin + dimensionsInCubes;
		for (var cubeX = begin.x; cubeX < end.x; ++cubeX) {
			for (var cubeY = begin.y; cubeY < end.y; ++cubeY) {
				for (var cubeZ = begin.z; cubeZ < end.z; ++cubeZ) {
					var cube = cubes[cubeX, cubeY, cubeZ];
          			if (cube == null) continue;
          			var cubeGridPosition = new Vector3i(cubeX, cubeY, cubeZ);
					var cubeMesh = CalculateRenderableCube(cube, ref visualVertexCount, ref collisionVertexCount, cubes, cubeGridPosition);
					cubeMeshes[cubeX, cubeY, cubeZ] = cubeMesh;
          			cubes[cubeX, cubeY, cubeZ] = cube;
				}
			}
		}
		return cubeMeshes;
	}
}