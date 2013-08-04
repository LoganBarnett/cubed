using UnityEngine;
using System.Collections;

[System.Serializable]
public class Vector3i {
	public int x = 0;
 	public int y = 0;
	public int z = 0;
	
	public Vector3i() {}
	
	public Vector3i(int newX, int newY, int newZ) {
		x = newX;
    	y = newY;
    	z = newZ;
	}
	
	public Vector3i(float newX, float newY, float newZ) {
		x = (int)newX;
    	y = (int)newY;
    	z = (int)newZ;
	}
	
	public Vector3i(Vector3 vector) {
		x = (int)vector.x;
		y = (int)vector.y;
		z = (int)vector.z;
	}
	
	public override int GetHashCode() {
		return ToString().GetHashCode();
	}
	
	public override string ToString() {
		return string.Format("({0}, {1}, {2})", x, y, z);
	}
	
	public Vector3 ToVector3() {
		return new Vector3(x, y, z);
	}
	
	public Vector3i Clone() {
		return new Vector3i(x, y, z);
	}
	
	public static Vector3i operator *(Vector3i left, Vector3i right) {
		return new Vector3i(left.x * right.x, left.y * right.y, left.z * right.z);
	}
	
	public static Vector3i operator /(Vector3i left, Vector3i right) {
		return new Vector3i(left.x / right.x, left.y / right.y, left.z / right.z);
	}
	
	public static Vector3i operator *(Vector3i left, float f) {
		return new Vector3i(left.x * f, left.y * f, left.z * f);
	}
	
	public static Vector3i operator +(Vector3i left, Vector3i right) {
		return new Vector3i(left.x + right.x, left.y + right.y, left.z + right.z);
	}
	
	public static Vector3i operator +(Vector3i left, Vector3 right) {
		return new Vector3i(left.x + right.x, left.y + right.y, left.z + right.z);
	}
	
	public static Vector3i operator +(Vector3i left, int i) {
		return new Vector3i(left.x + i, left.y + i, left.z + i);
	}
	
	public static Vector3i operator -(Vector3i left, Vector3i right) {
		return new Vector3i(left.x - right.x, left.y - right.y, left.z - right.z);
	}
	
	public static Vector3i operator /(Vector3i numerator, float denominator) {
		return new Vector3i(numerator.x / denominator, numerator.y / denominator, numerator.z / denominator);
	}
	
	public static Vector3i operator /(Vector3i numerator, int denominator) {
		return new Vector3i(numerator.x / denominator, numerator.y / denominator, numerator.z / denominator);
	}
	
	public static bool operator ==(Vector3i left, Vector3i right) {
		var leftObject = left as object;
		var rightObject = right as object;
		if (leftObject == null && rightObject == null) return true;
    	if (leftObject != null && rightObject == null) return false;
    	if (leftObject == null && rightObject != null) return false;
    	return left.x == right.x && left.y == right.y && left.z == right.z;
	}
	
	public static bool operator !=(Vector3i left, Vector3i right) {
		var leftObject = left as object;
		var rightObject = right as object;
		
		if (leftObject == null && rightObject != null) return true;
		if (leftObject != null && rightObject == null) return true;
		if (leftObject == null && rightObject != null) return true;
    	if (leftObject == null && rightObject == null) return false;
    	return left.x != right.x || left.y != right.y || left.z != right.z;
	}
	
	public override bool Equals(object obj)
	{
		return base.Equals(obj);
	}
	
	public Vector3i Up    { get { return new Vector3i(x, y + 1, z); } }
	public Vector3i Down  { get { return new Vector3i(x, y - 1, z); } }
	public Vector3i Left  { get { return new Vector3i(x - 1, y, z); } }
	public Vector3i Right { get { return new Vector3i(x + 1, y, z); } }
	public Vector3i Front { get { return new Vector3i(x, y, z + 1); } }
	public Vector3i Back  { get { return new Vector3i(x, y, z - 1); } }
}