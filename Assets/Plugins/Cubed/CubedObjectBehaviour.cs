using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class CubedObjectBehaviour : MonoBehaviour {
	public Vector3i dimensionsInChunks = new Vector3i(1,1,1);
	public Vector3i chunkDimensions = new Vector3i(8,8,8);
  	public float cubeSize = 1f;
  	public Material material;
  	public Texture packedTexture;
  	public Rect[] textureAtlas;
  	public CubeLegend cubeLegend;
	public bool useMeshColliders = true;
			
  	// oh Unity, if only you could serialize Dictionaries, I would love you longer than the stars
  	// etc
	[HideInInspector] public List<Vector3i> chunkVectors;
	[HideInInspector] public List<Chunk> chunkChunks;
	[HideInInspector] public List<Vector3i> cubeVectors;
	[HideInInspector] public List<Cube> cubeCubes;
	
	
	Cube[,,] allCubes;
	Dictionary<string, Chunk> chunks; // using ToString()ed Vector3i
	
	public Cube[,,] Cubes { get { return allCubes; } }
	public Dictionary<string, Chunk> Chunks { get { return chunks; } }
	
	void Awake() {
		Initialize();
	}
	
	public void Initialize() {
		var cubeDimensions = dimensionsInChunks * chunkDimensions;
		allCubes = new Cube[cubeDimensions.x, cubeDimensions.y, cubeDimensions.z];
		if (cubeCubes != null) {
			foreach (var cube in cubeCubes) {
				allCubes[cube.indexes.x, cube.indexes.y, cube.indexes.z] = cube;
			}
		}
		
		chunks = new Dictionary<string, Chunk>();
		if (chunkVectors != null && chunkChunks	!= null) {
			for (var i = 0; i < chunkVectors.Count; ++i) {
				var chunk = chunkChunks[i];
        		chunk.cubeObject = this;
        		chunks[(chunkVectors[i]).ToString()] = chunk;
			}
		}
	}
	
	public void Generate(Cube[,,] allCubes) {
		DestroyChildren(); // patricide?
		GenerateChunks(dimensionsInChunks, allCubes, transform.position);
//		foreach (var chunk in Chunks.Values) {
//			chunk.Generate(Cubes);
//		}
	}
	
	public Cube GetCubeAt(Vector3i gridPosition) {
		try {
			return allCubes[gridPosition.x, gridPosition.y, gridPosition.z];
		} catch (System.Exception) {
			var message = string.Format("Provided: {0}\nDimensions: ({1}, {2}, {3)}", gridPosition, allCubes.GetLength(0), allCubes.GetLength(1), allCubes.GetLength(2));
			throw new System.IndexOutOfRangeException(message);
		}
	}
	
	public Cube GetCubeAt(Vector3 position) {
		var indexes = new Vector3i(position / cubeSize);
    	return GetCubeAt(indexes);
	}
	
	public Cube RemoveCubeAt(Vector3i cubeLocation) {
		var cube = allCubes[cubeLocation.x, cubeLocation.y, cubeLocation.z];
		if (cube == null) throw new System.Exception(string.Format("Null cube found at {0}", cubeLocation));
		if (cube.gameObject != null) Object.Destroy(cube.gameObject);
		allCubes[cubeLocation.x, cubeLocation.y, cubeLocation.z] = null;
		return cube;
	}
	
	public Cube RemoveCubeAt(Vector3 position) {
		var relativePosition = position - transform.position;
    	var cube = GetCubeAt(relativePosition);
    	if (cube == null) return null;
    	return RemoveCubeAt(cube.indexes);
	}
	
	public Cube PlaceCubeAt(Vector3 worldPosition, Cube cube) {
		var cubePlacement = GetGridPositionOf(worldPosition - transform.position);
    	return PlaceCubeAt(cubePlacement, cube);
	}
	
	public Cube PlaceCubeAt(Vector3 worldPosition, GameObject cube) {
		var cubePlacement = GetGridPositionOf(worldPosition - transform.position);
    	return PlaceCubeAt(cubePlacement, cube);
	}
	
	public Cube PlaceCubeAt(Vector3i gridPosition, Cube cube) {
		cube.indexes = gridPosition;
		cube.cubeSize = cubeSize;
		
		allCubes[gridPosition.x, gridPosition.y, gridPosition.z] = cube;
		Chunk chunk = null;
		if (!chunks.TryGetValue((gridPosition / chunkDimensions).ToString(), out chunk)) {
			var chunkGameObject = MakeChunk(gridPosition / chunkDimensions, transform.position);
			chunk = chunkGameObject.GetComponent<Chunk>();
		}
		cube.chunk = chunk;
    	return cube;
	}
	
	public Cube PlaceCubeAt(Vector3i gridPosition, GameObject cubeGameObject) {
		var originalCube = cubeGameObject.GetComponent<CubeBehaviour>().cube;
    	var cube = new Cube();
		cube.indexes = gridPosition;
		cube.cubeSize = cubeSize;
		cube.type = originalCube.type;
    	cube.gameObject = cubeGameObject;

	    allCubes[gridPosition.x, gridPosition.y, gridPosition.z] = cube;
		
		Chunk chunk = null;
		if (!chunks.TryGetValue((gridPosition / chunkDimensions).ToString(), out chunk)) {
			var chunkGameObject = MakeChunk(gridPosition / chunkDimensions, transform.position);
			chunk = chunkGameObject.GetComponent<Chunk>();
		}
		cube.chunk = chunk;
		
    	return cube;
	}
	
	public void Generate() {
		Generate(Cubes);
	}
	
	GameObject MakeChunk(Vector3i location, Vector3 offset) {
		var chunkGameObject = new GameObject();
	    chunkGameObject.AddComponent<MeshFilter>();
	    chunkGameObject.AddComponent<MeshRenderer>();
//	    chunkGameObject.AddComponent<MeshCollider>();
	    var chunkComponent = chunkGameObject.AddComponent<Chunk>();
	    chunkComponent.cubeSize = cubeSize;
	    chunkComponent.blockMaterial = material;
	    chunkGameObject.name = "Chunk";
	    chunkGameObject.tag = "cubed_chunk";
	    chunkComponent.cubeLegend = cubeLegend;
	    chunkGameObject.transform.parent = gameObject.transform;
	    //chunkGameObject.transform.localScale = Vector3.one
		
		chunkGameObject.transform.position = (new Vector3(location.x * chunkDimensions.x, location.y * chunkDimensions.y, location.z * chunkDimensions.z) * cubeSize) + offset;
		chunkGameObject.name = string.Format("Chunk {0}, {1}, {2}", location.x, location.y, location.z);
		var chunk = chunkGameObject.GetComponent<Chunk>();

    	chunk.cubeObject = this;
    	chunk.dimensionsInCubes = new Vector3i(chunkDimensions.x, chunkDimensions.y, chunkDimensions.z);
	    chunk.gridPosition = location;
	    chunks[location.ToString()] = chunk;
		
	    return chunkGameObject;
	}
	
	public Vector3i GetGridPositionOf(Vector3 worldPosition) {
		var cubePosition = worldPosition / cubeSize;
    	return new Vector3i(cubePosition);
	}
	
	public void Save() {
		cubeCubes.Clear();
    	cubeVectors.Clear();
    	foreach (var cube in Cubes) {
      		cubeCubes.Add(cube);
      		if (cube != null) cubeVectors.Add(cube.indexes);
		}
	}
	
	public Chunk GetChunkAt(Vector3 position) {
		var x = position.x / (chunkDimensions.x  * cubeSize);
    	var y = position.y / (chunkDimensions.y * cubeSize);
    	var z = position.z / (chunkDimensions.z  * cubeSize);
    	var key = new Vector3i(new Vector3(x, y, z));
    	return chunks[key.ToString()];
	}
	
	public Chunk GetChunkAt(Vector3i position) {
		return chunks[position.ToString()];
	}
	
	public void GenerateChunks(Vector3i newDimensionsInChunks, Cube[,,] cubes, Vector3 offset) {
		allCubes = cubes;

	    dimensionsInChunks = newDimensionsInChunks;
	    // TODO: Put this back in when preprocessor directives are supported in Boo
	    // Use UNITY_EDITOR
	    // CubeGeneratorProgressEditor.Start(dimensionsInChunks, chunkDimensions)
	
	    var chunks = new Dictionary<Vector3i, Chunk>();
		
	    for (var x = 0; x < dimensionsInChunks.x; ++x) {
	      for (var y = 0; y < dimensionsInChunks.y; ++y) {
	        for (var z = 0; z < dimensionsInChunks.z; ++z) {
	     	     	var location = new Vector3i(x, y, z);
	       			GenerateChunk(location, cubes, offset);
				}
			}
		}
	
	    chunkVectors = chunks.Keys.ToList();
	    chunkChunks = chunks.Values.ToList();
	
	    cubeVectors = new List<Vector3i>();
	    cubeCubes = new List<Cube>();
//	    foreach (var cube in cubes) {
//	      if (cube == null) continue;
//	      cubeCubes.Add(cube);
//	      cubeVectors.Add(cube.indexes);
//		}
		
//	    # TODO: Put this back in when preprocessor directives are supported in Boo
//	    # Use UNITY_EDITOR
//	    #CubeGeneratorProgressEditor.End() 
	}
	
	public void GenerateChunk(Vector3i location, Cube[,,] cubes, Vector3 offset) {
//		# TODO: Put this back in when preprocessor directives are supported in Boo
//    # Use UNITY_EDITOR
//    #CubeGeneratorProgressEditor.ReportChunk(Vector3i(location.x, location.y, location.z))

    	var chunkGameObject = MakeChunk(location, offset);
    	var chunk = chunkGameObject.GetComponent<Chunk>();

	    chunk.Generate(cubes);
	}
	
	void DestroyChildren() {
		var children = new List<GameObject>();
    	foreach (Transform childTransform in transform) {
      		children.Add(childTransform.gameObject);
		}
    	children.ForEach(child => GameObject.DestroyImmediate(child));
	}
}