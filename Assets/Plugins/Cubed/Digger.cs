using UnityEngine;
using System.Collections;
using System.Linq;

public class Digger : MonoBehaviour {
	public LayerMask ignoreLayers;
	CubedObjectBehaviour cubedObject;
	// Use this for initialization
	void Awake() {
		var cubedObjectGameObject = GameObject.Find("Cube Terrain");
		if (cubedObjectGameObject == null) throw new System.Exception("There must be a game object named 'Cube Terrain' on the scene for Digger to work");
		cubedObject = cubedObjectGameObject.GetComponent<CubedObjectBehaviour>();
	}
	
	public void Dig(Ray ray, float digDistance) {
		var hit = new RaycastHit();
    	if (!Physics.Raycast(ray, out hit, digDistance, ~ignoreLayers.value)) return;
    
    	var worldPoint = hit.point + (ray.direction * 0.1f); // need to overpenetrate a little
    	var cube = cubedObject.RemoveCubeAt(worldPoint);
    	if (cube != null) {
			cubedObject.Generate();
			BroadcastMessage("DigComplete", cube, SendMessageOptions.DontRequireReceiver);
		}
	}
}