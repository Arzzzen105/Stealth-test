extends Polygon2D

@export var radius : int = 6
@export var step_angle : float = PI/36

func _ready():
	var angle :float = step_angle
	var point = Vector2(radius, angle)
	var round_polygon : PackedVector2Array
	round_polygon.append(point)
	while angle < 2*PI:
		
		point = Vector2(radius, 0).rotated(angle)
		angle += step_angle
		round_polygon.append(point)
		
	polygon = round_polygon
