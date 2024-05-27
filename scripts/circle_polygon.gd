extends Polygon2D

@onready var edge = $edge


@export var radius : int = 6
@export var step_angle : float = PI/36
@export var edge_color : Color = Color(1, 1, 1)
@export_range(0, 5) var edge_size : float = 1.0

var round_polygon : PackedVector2Array = []

func _ready():
	var angle :float = step_angle
	var point = Vector2(radius, angle)
	round_polygon.append(point)
	while angle < 2*PI:
		point = Vector2(radius, 0).rotated(angle)
		angle += step_angle
		round_polygon.append(point)
		
	polygon = round_polygon
	if edge_size == 0 or edge_color.a == 1:
		edge.default_color = edge_color
		edge.width = edge_size
		edge.points = round_polygon
