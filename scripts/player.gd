extends CharacterBody2D

@onready var sprite = $sprite

@export_category("Player")
@export var speed : int = 80

var dir : Vector2 = Vector2.ZERO

func _ready():
	pass
	
func _physics_process(delta):
	dir.x = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	dir.y = Input.get_action_strength("player_down") - Input.get_action_strength("player_up")
	dir = dir.normalized()
	
	velocity = dir * speed
	
	move_and_slide()
