namespace Cubed

import UnityEngine
import System.Collections.Generic

class RenderableBlock:
	[Property(Vertices)]
	vertices = List[of Vector3]()
	
	[Property(Triangles)]
	triangles = List[of int]()
