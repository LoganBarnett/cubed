Warning: Here be dragons. API is still undergoing some love.

What in the world is this? Cubed is a library for dealing with voxels in Unity.

What are voxels? Voxels are cubes used to make objects in 3 dimensional space much in the way that pixels can be used to make 2 dimensional images. Think Minecraft for a real world example.

How do I use it? 
================

Installation:
-------------

1. Get the library from here or the Asset Store (coming soon!) 
2. Create a game object
3. Add the CubedObject behaviour to the game object 
4. Create Cube Definitions in the inspector and assign materials to sides (this is your palette)
5. Click Pack Textures in the inspector for the CubedObject
6. Give the CubedObject some data (or use the editor coming soon) 
7. Click Bake Cubes in the inspector for the CubedObject

Adding Cubes
------------
## Boo
```boo
placeDistance = 5f
mask = 0 # can be omitted if not coming out of a capsule collider
hit = RaycastHit()
return false unless Physics.Raycast(aimingRay, hit, placeDistance, ~mask)

worldPoint = hit.point - (aimingRay.direction * 0.001f) # need to underpenetrate a little

if hit.collider.CompareTag("cubed_cube"):
  cubedObject.PlaceCubeAt(worldPoint, cube)      
  return true
return false
```
## C#

## UnityScript

Removing Cubes
--------------
## Boo
```boo
distance = 5f
mask = 0 # can be omitted if not coming out of a capsule collider
hit = RaycastHit()
return null unless Physics.Raycast(ray, hit, distance, ~mask)

worldPoint = hit.point + (ray.direction * 0.1f) # need to overpenetrate a little
block = cubedObject.RemoveCubeAt(worldPoint)
cubedObject.GetChunkAt(worldPoint).Generate(cubedObject.cubeTerrain.Cubes)
BroadcastMessage("DigComplete", block, SendMessageOptions.DontRequireReceiver) unless block == null
```boo

## C#

## UnityScript

Coming soon!
------------
* Collisions
* Editor in Unity

