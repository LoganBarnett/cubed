using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

// TODO: Make an editor that detects how optimial the chunk dimensions are and reports (or warns) of this status.
public class CubedObjectBehaviour : MonoBehaviour {
	public Vector3i dimensionsInChunks = new Vector3i(1,1,1);
	public Vector3i chunkDimensions = new Vector3i(8,8,8);
  	public float cubeSize = 1f;
  	public Material material;
  	public Texture packedTexture;
  	public Rect[] textureAtlas;
  	public CubeLegend cubeLegend;
	public ColliderType colliderType = ColliderType.AxisAlignedBoundingBoxPerCube;
	public string chunkTag;
	public string cubeTag;
	
	public delegate void OnRemovedCubeHandler(Cube cube);
	public OnRemovedCubeHandler OnRemovedCube;
			
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
	
	// would memoize, but Unity provides no hooks if fields change
	public Vector3i TotalDimensions {
		get {
			return dimensionsInChunks * chunkDimensions;
		}
	}
	
	// would memoize, but Unity provides no hooks if fields change
	public int TotalCubes {
		get {
			return TotalDimensions.x * TotalDimensions.y * TotalDimensions.z;
		}
	}
	
	void Awake() {
		Initialize();
	}
	
	public void Initialize() {
		ClearCubes();
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
		
		if(cubeLegend == null) cubeLegend = new CubeLegend();
		cubeLegend.Initialize();
		if(material == null) material = new Material(Shader.Find("Diffuse"));
	}
	
	// TODO: Consider yielding back for async goodness
	public void GenerateUnityArtifacts() {
		DestroyChildren(); // patricide?
		GenerateChunkBehaviours();
	}
	
	public void Generate(Cube[,,] allCubes) {
		GenerateChunks(dimensionsInChunks, allCubes);
//		foreach (var chunk in Chunks.Values) {
//			chunk.Generate(Cubes);
//		}
	}
	
	public Cube GetCubeAt(Vector3i gridPosition) {
		try {
			return allCubes[gridPosition.x, gridPosition.y, gridPosition.z];
		} catch (System.Exception) {
			var message = string.Format("Provided: {0}\nDimensions: ({1}, {2}, {3})", gridPosition, allCubes.GetLength(0), allCubes.GetLength(1), allCubes.GetLength(2));
			throw new System.IndexOutOfRangeException(message);
		}
	}
	
	public Vector3 GetWorldPositionOf(Vector3i indexes) {
		return transform.position + (indexes * cubeSize).ToVector3();
	}
	
	public Cube GetCubeAt(Vector3 worldPosition) {
		var indexes = new Vector3i((worldPosition - transform.position) / cubeSize);
    	return GetCubeAt(indexes);
	}
	
	public bool IsPositionWithinBounds(Vector3i position) {
		// TODO: Test if throwing an exception by trying to get the index is faster than these checks
		return !(position.x < 0 || position.y < 0 || position.z < 0 ||
			position.x >= TotalDimensions.x || position.y >= TotalDimensions.y || position.z >= TotalDimensions.z);
	}
	
	public bool IsPositionWithinBounds(Vector3 worldPosition) {
		try {
			GetCubeAt(worldPosition);
			return true;
		}
		catch(System.IndexOutOfRangeException) {
			return false;
		}
	}
	
	public bool IsPositionOccupied(Vector3i position) {
		if(colliderType == ColliderType.None) return false;
		var cube = GetCubeAt(position);
		if(cube == null) return false;
		return cubeLegend.cubeDefinitions[cube.type].hasCollision;
	}
	
	public bool IsPositionOccupied(Vector3 worldPosition) {
		if(colliderType == ColliderType.None) return false;
		var cube = GetCubeAt(worldPosition);
		if(cube == null) return false;
		return cubeLegend.cubeDefinitions[cube.type].hasCollision;
	}
	
	public bool IsPositionOccupied(Vector3 worldPosition, float radius) {
		if(colliderType == ColliderType.None) return false;
		var cubes = GetCubesInRadius(worldPosition, radius);
		if(cubes.Count() == 0) return false;
		return cubes.Any(c => cubeLegend.cubeDefinitions[c.type].hasCollision);
	}
	
	public Cube[] GetCubesInRadius(Vector3 worldPosition, float radius) {
		// TODO: Implement
		return null;
	}
	
	public Cube RemoveCubeAt(Vector3i cubeLocation) {
		var cube = allCubes[cubeLocation.x, cubeLocation.y, cubeLocation.z];
		if (cube == null) throw new System.Exception(string.Format("Null cube found at {0}", cubeLocation));
		if (cube.gameObject != null) Object.Destroy(cube.gameObject);
		allCubes[cubeLocation.x, cubeLocation.y, cubeLocation.z] = null;
		cube.indexes = cubeLocation;
		SendMessage("OnCubeRemoved", cube, SendMessageOptions.DontRequireReceiver);
		OnRemovedCube(cube);
		return cube;
	}
	
	public Cube RemoveCubeAt(Vector3 position) {
    	var cube = GetCubeAt(position);
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
		
		try {
			allCubes[gridPosition.x, gridPosition.y, gridPosition.z] = cube;
		} catch(System.IndexOutOfRangeException) {
			Debug.LogError(string.Format("Couldn't place cube at {0}. Dimensions: {1}", gridPosition, TotalDimensions));
			throw;
		}
		Chunk chunk = null;
		if (!chunks.TryGetValue((gridPosition / chunkDimensions).ToString(), out chunk)) {
			chunk = new Chunk();
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
			chunk = new Chunk();
		}
		cube.chunk = chunk;
		
    	return cube;
	}
	
	public Cube FindNearestCubeFrom(Vector3 worldPosition) {
		var allCubes = new List<Cube>();
		foreach(var cube in Cubes) {
			allCubes.Add(cube);
		}
		var existingCubes = allCubes.Where(c => c != null);
		if(existingCubes.Count() == 0) return null;
		
		var closestCube = existingCubes.First();
		var closestDistance = Vector3.Distance(closestCube.WorldPosition, transform.position);
		foreach(var cube in existingCubes) {
			var distance = Vector3.Distance(cube.WorldPosition, transform.position);
			if(distance < closestDistance) {
				closestDistance = distance;
				closestCube = cube;
			}
		}
		return closestCube;
	}
	
	public void Generate() {
		Generate(Cubes);
	}
	
	public int PackTextures() {
		var textureLists = cubeLegend.cubeDefinitions.Select(cd => cd.Textures);
		var textures = new List<Texture2D>();
		foreach(var textureList in textureLists) textures.AddRange(textureList);
		var texture = new Texture2D(1024, 1024); // TODO: Figure out how big our texture needs to be
//		texture.mipMapBias = -0.5f;
		textureAtlas = texture.PackTextures(textures.ToArray(), 1);
		cubeLegend.textureAtlas = textureAtlas.ToList();
		material.mainTexture = texture;
		packedTexture = texture; // for serialization
		material.color = Color.white;
		return textures.Count();
	}
	
	ChunkBehaviour MakeChunkBehaviour(Chunk chunk) {
		var chunkGameObject = new GameObject();
	    chunkGameObject.AddComponent<MeshFilter>();
	    chunkGameObject.AddComponent<MeshRenderer>();
		chunkGameObject.tag = chunkTag;
		chunkGameObject.transform.parent = gameObject.transform;
//	    chunkGameObject.AddComponent<MeshCollider>();
	    var chunkComponent = chunkGameObject.AddComponent<ChunkBehaviour>();
		var location = chunk.gridPosition;
		chunkGameObject.name = string.Format("Chunk {0}, {1}, {2}", location.x, location.y, location.z);
		chunkGameObject.transform.position = (chunk.gridPosition * chunkDimensions).ToVector3() * cubeSize;
		return chunkComponent;
	}
	
	Chunk MakeChunk(Vector3i location) {
		var chunk = new Chunk();
	    chunk.cubeSize = cubeSize;
	    chunk.blockMaterial = material;
	    chunk.cubeLegend = cubeLegend;
	    //chunkGameObject.transform.localScale = Vector3.one
		chunk.gridPosition = location;
    	chunk.cubeObject = this;
    	chunk.dimensionsInCubes = chunkDimensions.Clone();
	    chunk.gridPosition = location;
	    chunks[location.ToString()] = chunk;
		
	    return chunk;
	}
	
	public Vector3i GetGridPositionOf(Vector3 worldPosition) {
		var cubePosition = worldPosition / cubeSize;
    	return new Vector3i(cubePosition);
	}
	
	public void Save() {
		if(cubeCubes == null) cubeCubes = new List<Cube>();
		if(cubeVectors == null) cubeVectors = new List<Vector3i>();
		cubeCubes.Clear();
    	cubeVectors.Clear();
    	foreach(var cube in Cubes) {
      		cubeCubes.Add(cube);
      		if(cube != null) cubeVectors.Add(cube.indexes);
			
			if(cube != null && cube.chunk == null) Debug.Log("chunk missing from a cube. How did this happen?");
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
	
	public void GenerateChunks(Vector3i newDimensionsInChunks, Cube[,,] cubes) {
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
	       			GenerateChunk(location, cubes);
				}
			}
		}
	
	    chunkVectors = chunks.Keys.ToList();
	    chunkChunks = chunks.Values.ToList();
	
	    cubeVectors = new List<Vector3i>();
//	    cubeCubes = new List<Cube>();
//	    foreach (var cube in cubes) {
//	      if (cube == null) continue;
//	      cubeCubes.Add(cube);
//	      cubeVectors.Add(cube.indexes);
//		}
		
//	    # TODO: Put this back in when preprocessor directives are supported in Boo
//	    # Use UNITY_EDITOR
//	    #CubeGeneratorProgressEditor.End() 
	}
	
	public void GenerateChunk(Vector3i location, Cube[,,] cubes) {
//		# TODO: Put this back in when preprocessor directives are supported in Boo
//    # Use UNITY_EDITOR
//    #CubeGeneratorProgressEditor.ReportChunk(Vector3i(location.x, location.y, location.z))

    	var chunk = MakeChunk(location);

	    chunk.Generate(cubes);
	}
	
	public void ClearCubes() {
		allCubes = new Cube[TotalDimensions.x, TotalDimensions.y, TotalDimensions.z];
	}
	
	/// <summary>
	/// Clones from another CubedObjectBehavior. This can be helpful for generators that need to run in threads and
	/// combine their results later.
	/// </summary>
	/// <param name='other'>
	/// The CubedObjectBehavior to clone from.
	/// </param>
	public void CloneFrom(CubedObjectBehaviour other) {
		allCubes = new Cube[other.TotalDimensions.x, other.TotalDimensions.y, other.TotalDimensions.z];
		System.Array.Copy(other.allCubes, allCubes, other.allCubes.Length);
		material = other.material;
		chunkDimensions = other.chunkDimensions.Clone();
		dimensionsInChunks = other.dimensionsInChunks.Clone();
		colliderType = other.colliderType;
		cubeLegend = other.cubeLegend.Clone();
		cubeSize = other.cubeSize;
		
		// TODO: Add more things to copy over.
	}
	
	class LineFill {
		public int XMin {get; set;}
		public int XMax {get; set;}
		public int Y {get; set;}
		public FillDirection Direction {get; set;}
		public bool ShouldPaintLeft {get; set;}
		public bool ShouldPaintRight {get; set;}
	}
	
	enum FillDirection {
		Neither,
		Up,
		Down,
	}
	
	// TODO: Add an option to indicate an axis and perhaps a 3D mode
	// Good notes from here http://en.wikipedia.org/wiki/Flood_fill
	// shamelessly ported from http://will.thimbleby.net/scanline-flood-fill/
	// favoring the Scanline approach
	/// <summary>
	/// Fills the area with cubes, calling the drawCallback for each cube drawn.
	/// At the moment, only works on the x/z axis (substitude y for z)
	/// </summary>
	/// <param name='startPosition'>
	/// Starting position, currently only uses the x/z coordinates.
	/// </param>
	/// <param name='shouldDrawTestCallback'>
	/// Called to determine if the cube should be drawn (true), or serves as a border for the fill (false).
	/// </param>
	/// <param name='drawCallback'>
	/// Called to handle the drawing of the cube
	/// </param>
	/// <param name='diagonal'>
	/// Whether or not to fill diagnolly as well as up/down/left/right. 
	/// </param>
	public void FillArea(Vector3i startPosition,
			     System.Func<int, int, bool> shouldDrawTestCallback,
			     System.Action<int, int> drawCallback,
			     bool diagonal = false) {
		
		var width = allCubes.GetLength(0);
		var height = allCubes.GetLength(2);
		
		drawCallback(startPosition.x, startPosition.z);
		var lines = new Stack<LineFill>();
		lines.Push(new LineFill {
			XMin = startPosition.x, 
			XMax = startPosition.x,
			Y = startPosition.z,
			Direction = FillDirection.Neither,
			ShouldPaintLeft = true,
			ShouldPaintRight = true,
		});
		
		while(lines.Count != 0) {
			var lineFill = lines.Pop();
			var moveUp = lineFill.Direction == FillDirection.Up;
			var moveDown = lineFill.Direction == FillDirection.Down;
			var xMax = lineFill.XMax;
			var xMin = lineFill.XMin;
			var y = lineFill.Y;
			
			if(lineFill.ShouldPaintLeft) {
				while(xMin > 0 && shouldDrawTestCallback(xMin - 1, y)) {
					--xMin;
					drawCallback(xMin, y);
				}
			}
			
			if(lineFill.ShouldPaintRight) {
				while(xMax < width - 1 && shouldDrawTestCallback(xMax + 1, y)) {
					++xMax;
					drawCallback(xMax, y);
				}
			}
			
			if(diagonal) {
				// extend range looked at for next lines
				if(xMin > 0) --xMin;
				if(xMax < width - 1) ++xMax;
			}
			else {
				// extend range ignored from previous line
				--lineFill.XMin;
				++lineFill.XMax;
			}
			
			if(y < height) {
				AddNextFillLine(
					lineFill,
					xMin,
					xMax,
					y + 1,
					!moveUp,
					true,
					height,
					lines,
					shouldDrawTestCallback,
					drawCallback);
			}
			if(y > 0) {
				AddNextFillLine(
					lineFill,
					xMin,
					xMax,
					y - 1,
					!moveDown,
					false,
					height,
					lines,
					shouldDrawTestCallback,
					drawCallback);
			}
		}
	}
	
	void AddNextFillLine(LineFill line,
						 int xMin,
						 int xMax,
						 int y,
						 bool isNext,
						 bool downwards,
					     int height,
						 Stack<LineFill> lines,
						 System.Func<int, int, bool> shouldDrawTestCallback,
						 System.Action<int, int> drawCallback) {
		var inRange = false;
		var rangeXMin = xMin;
		int x; // needs use outside of the loop
		for(x = xMin; x <= xMax; ++x) {
			// skip testing if testing previous line within previous range
			var empty = (isNext || (x < line.XMin || x > line.XMax)) && y < height && shouldDrawTestCallback(x, y);
			if(!inRange && empty) {
				rangeXMin = x;
				inRange = true;
			}
			else if(inRange && !empty) {
				lines.Push(new LineFill {
					XMin = rangeXMin,
					XMax = x - 1,
					Y = y,
					Direction = downwards ? FillDirection.Down : FillDirection.Up,
					ShouldPaintLeft = xMin == rangeXMin,
					ShouldPaintRight = false,
				});
				inRange = false;
			}
			
			if(inRange) {
				drawCallback(x, y);
			}
			
			// skip
			if(!isNext && x == line.XMin) {
				x = line.XMax;
			}
		}
		
		if(inRange) {
			lines.Push(new LineFill {
				XMin = rangeXMin,
				XMax = x - 1,
				Y = y,
				Direction = downwards ? FillDirection.Down : FillDirection.Up,
				ShouldPaintLeft = rangeXMin == xMin,
				ShouldPaintRight = true,
			});
		}
	}
	
	
	void GenerateChunkBehaviours() {
		foreach(var chunk in chunks.Values) {
			var chunkName = string.Format(
				"Chunk {0} {1} {2}",
				chunk.gridPosition.x,
				chunk.gridPosition.y,
				chunk.gridPosition.z
			);
			var chunkGameObject = new GameObject(chunkName, typeof(ChunkBehaviour));
			chunkGameObject.transform.parent = transform;
			chunkGameObject.GetComponent<ChunkBehaviour>().ApplyChunkSettings(chunk, this);
		}
	}
	
	void DestroyChildren() {
		var children = new List<GameObject>();
    	foreach (Transform childTransform in transform) {
			if(childTransform.GetComponent<ChunkBehaviour>() != null) children.Add(childTransform.gameObject);
		}
		if(Application.isPlaying) children.ForEach(GameObject.Destroy);
		else children.ForEach(GameObject.DestroyImmediate);
	}
}