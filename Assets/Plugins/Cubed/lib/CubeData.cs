public class CubeData {
  public Vector3i Indexes { get; set; }
  public int Type { get; set; }
  
  public Cube ToCube() {
		var cube = new Cube();
		cube.type = Type;
		cube.indexes = Indexes;
		return cube;
  }
}