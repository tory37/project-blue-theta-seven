class_name HexUtils
extends Node

## Utility for Axial Hexagon Coordinates.
## Uses the "Pointy Top" orientation.

# Directions for axial coordinates (q, r)
const DIRECTIONS = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

static func axial_to_pixel(q: int, r: int, size: float) -> Vector2:
	var x = size * (sqrt(3) * q + sqrt(3)/2 * r)
	var y = size * (3.0/2 * r)
	return Vector2(x, y)

static func pixel_to_axial(x: float, y: float, size: float) -> Vector2i:
	var q = (sqrt(3)/3 * x - 1.0/3 * y) / size
	var r = (2.0/3 * y) / size
	return axial_round(q, r)

static func axial_round(q: float, r: float) -> Vector2i:
	var s = -q - r
	var rq = round(q)
	var rr = round(r)
	var rs = round(s)

	var q_diff = abs(rq - q)
	var r_diff = abs(rr - r)
	var s_diff = abs(rs - s)

	if q_diff > r_diff and q_diff > s_diff:
		rq = -rr - rs
	elif r_diff > s_diff:
		rr = -rq - rs
	
	return Vector2i(int(rq), int(rr))

static func get_neighbors(q: int, r: int) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for d in DIRECTIONS:
		neighbors.append(Vector2i(q + d.x, r + d.y))
	return neighbors

static func get_distance(q1: int, r1: int, q2: int, r2: int) -> int:
	return int((abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2)
