namespace Cubed

import UnityEngine
import System.Linq.Enumerable

class BlockTerrain:
	[Property(ChunkWidth)]
	chunkWidth = 10;
	[Property(BlockWidth)]
	blockWidth = 10f;
	
	def GenerateBlockGrid():
		grid = matrix(Block, 3, 1, 1)
		grid[0, 0, 0] = Block()
		grid[1, 0, 0] = Block()
		grid[2, 0, 0] = Block()
		return grid
		
	# TODO: pass an triangle count by ref so we know how far we are with triangles
	def CalculateRenderableBlock(x as int, y as int, z as int, ref vertexCount as int, blocks as (Block, 3)):
		renderableBlock = RenderableBlock()
		block = blocks[x,y,z]
		return renderableBlock if block == null
		vx = x * blockWidth
		vy = y * blockWidth
		vz = z * blockWidth
		
		# TODO: implement a lookaround and don't make verts/tris when adjacent to opaque	
		AddBottomToBlock(renderableBlock, Vector3(vx, vy, vz), vertexCount)
		AddTopToBlock(renderableBlock, Vector3(vx, vy, vz), vertexCount)
		AddRightToBlock(renderableBlock, Vector3(vx, vy, vz), vertexCount)
		AddLeftToBlock(renderableBlock, Vector3(vx, vy, vz), vertexCount)
		AddFrontToBlock(renderableBlock, Vector3(vx, vy, vz), vertexCount)
		AddBackToBlock(renderableBlock, Vector3(vx, vy, vz), vertexCount)
		
		return renderableBlock
		
	def AddBottomToBlock(block as RenderableBlock, position as Vector3, ref vertexCount as int):
		block.Vertices.Add(position)
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
		block.Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
		
		AddTriangles(block, vertexCount)
		vertexCount += 4;
		
	def AddTopToBlock(block as RenderableBlock, position as Vector3, ref vertexCount as int):
		block.Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
		block.Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
		
		AddTriangles(block, vertexCount)
		vertexCount += 4;
		
	def AddRightToBlock(block as RenderableBlock, position as Vector3, ref vertexCount as int):
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
		
		AddTriangles(block, vertexCount)
		vertexCount += 4;
		
	def AddLeftToBlock(block as RenderableBlock, position as Vector3, ref vertexCount as int):
		block.Vertices.Add(Vector3(position.x, position.y, position.z))
		block.Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))
		block.Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
		block.Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
		
		AddTriangles(block, vertexCount)
		vertexCount += 4;
	
	def AddFrontToBlock(block as RenderableBlock, position as Vector3, ref vertexCount as int):
		block.Vertices.Add(Vector3(position.x, position.y, position.z + blockWidth))
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z + blockWidth))
		block.Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z + blockWidth))
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z + blockWidth))
		
		AddTriangles(block, vertexCount)
		vertexCount += 4;
		
	def AddBackToBlock(block as RenderableBlock, position as Vector3, ref vertexCount as int):
		block.Vertices.Add(Vector3(position.x, position.y, position.z))
		block.Vertices.Add(Vector3(position.x, position.y + blockWidth, position.z))
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y, position.z))
		block.Vertices.Add(Vector3(position.x + blockWidth, position.y + blockWidth, position.z))
		
		AddTriangles(block, vertexCount)
		vertexCount += 4;
	
	def AddTriangles(block as RenderableBlock, vertexCount as int):
		# need this order to appear from below
		triangles = (0, 1, 2, 1, 3, 2).Select({i| i + vertexCount})
		block.Triangles.AddRange(triangles)
		
	def GenerateRenderableBlocks(blocks as (Block, 3)):
		renderableblocks = List[of RenderableBlock]()
		vertexCount = 0
		for x in range(len(blocks, 0)):
			for y in range(len(blocks, 1)):
				for z in range(len(blocks, 2)):
					renderableBlock = CalculateRenderableBlock(x, y, z, vertexCount, blocks)
					renderableblocks.Add(renderableBlock)
		return renderableblocks.ToArray()