namespace Cubed

class Vector3i:
	public x as int
	public y as int
	public z as int

	def constructor(newX as int, newY as int, newZ as int):
		x = newX
		y = newY
		z = newZ
		
	Up as Vector3i:
	  get:
	    return Vector3i(x, y + 1, z)
	    
	Down as Vector3i:
	  get:
	    return Vector3i(x, y - 1, z)
	    
  Left as Vector3i:
    get:
      return Vector3i(x - 1, y, z)
      
  Right as Vector3i:
    get:
      return Vector3i(x + 1, y, z)
  
  Front as Vector3i:
    get:
      return Vector3i(x, y, z + 1)
  
  Back as Vector3i:
    get:
      return Vector3i(x, y, z - 1)