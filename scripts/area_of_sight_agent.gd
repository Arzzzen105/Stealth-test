extends Area2D

@export_category("AreaOfSightAgent")
@export var shape : CircleShape2D
@export var parent_node : Node2D
@export_range(1, 16, 1, "or_greater") var baked_points_amount : int = 8

@onready var hitbox = $Hitbox

var step_angle : float
var baked_points : Array[Vector2] = []

func _ready():
	hitbox.shape = shape
	step_angle = 2 * PI / baked_points_amount
	set_baked_points()
	
func set_baked_points():
	
	for i : int in range(baked_points_amount):
		baked_points.append(Vector2(shape.radius, 0).rotated(i * step_angle))
