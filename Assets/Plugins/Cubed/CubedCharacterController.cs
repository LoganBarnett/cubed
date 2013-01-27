using UnityEngine;
using System.Collections;

public class CubedCharacterController : MonoBehaviour {
	public CubedObjectBehaviour cubedObject;
	
	Transform cachedTransform; // optimizated for mobile
	
	public void Awake() {
		cachedTransform = transform;
	}
	
	// at the moment only accounts for 2d
	public void Move(Vector3 translation) {
		var previousPosition = cachedTransform.position;
//		characterController.Move(maxVelocity * transform.forward * Time.deltaTime);
		cachedTransform.Translate(translation, Space.World);
		if(!cubedObject.IsPositionWithinBounds(cachedTransform.position) || cubedObject.IsPositionOccupied(cachedTransform.position)) {
			// eventually I'll want this to work with 3d so there will be many permutations to attempt (x + z, y + z, x + y, etc)
			// for now we just do x and z
			cachedTransform.position = previousPosition;
			var horizontalOnly = translation;
//			horizontalOnly.y = 0f;
			horizontalOnly.z = 0f;
			cachedTransform.Translate(horizontalOnly, Space.World);
			if(!cubedObject.IsPositionWithinBounds(cachedTransform.position) || cubedObject.IsPositionOccupied(cachedTransform.position)) {
				cachedTransform.position = previousPosition;
				var verticalOnly = translation;
				verticalOnly.x = 0f;
				cachedTransform.Translate(verticalOnly, Space.World);
				if(!cubedObject.IsPositionWithinBounds(cachedTransform.position) || cubedObject.IsPositionOccupied(cachedTransform.position)) cachedTransform.position = previousPosition;
			}
		}
	}
}
