class CubeData:
  [Property(Indexes)]
  public indexes as Vector3i
  [Property(Type)]
  public type = 0
  
  def ToCube():
    Cube(Type: type, Indexes: indexes)
  