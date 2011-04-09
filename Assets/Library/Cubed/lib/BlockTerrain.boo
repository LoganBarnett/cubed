namespace Cubed

import UnityEngine
import System.Linq.Enumerable

class BlockTerrain:
	[Property(ChunkWidth)]
	chunkWidth = 10
	[Property(ChunkHeight)]
	chunkHeight = 10
	[Property(ChunkDepth)]
	chunkDepth = 10
	
	[Property(BlockWidth)]
	blockWidth = 10f
	
	def GenerateFilledBlockGrid():
		grid = matrix(Block, ChunkWidth, ChunkHeight, ChunkDepth)
		for x in range(ChunkWidth):
			for y in range(ChunkHeight):
				for z in range(ChunkDepth):
					grid[x, y, z] = Block()
		return grid
		
	# TODO: pass an triangle count by ref so we know how far we are with triangles
	def CalculateRenderableBlock(x as int, y as int, z as int, ref vertexCount as int, blocks as (Block, 3)):
		renderableBlock = RenderableBlock(BlockWidth: blockWidth)
		block = blocks[x,y,z]
		return renderableBlock if block == null
		
		gridPosition = Vector3i(x, y, z)
		renderableBlock.CalculateRenderableProperties(gridPosition, vertexCount, blocks)
		
		return renderableBlock
		
	def GenerateRenderableBlocks(blocks as (Block, 3)):
		renderableblocks = List[of RenderableBlock]()
		vertexCount = 0
		for x in range(len(blocks, 0)):
			for y in range(len(blocks, 1)):
				for z in range(len(blocks, 2)):
					renderableBlock = CalculateRenderableBlock(x, y, z, vertexCount, blocks)
					renderableblocks.Add(renderableBlock)
		return renderableblocks.ToArray()