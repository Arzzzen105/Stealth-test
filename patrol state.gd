extends State

@onready var timer = $wait_timer

@export var enemy : PatrolEnemy
var player : CharacterBody2D
var path_array : Array
var current_point : int = 0
var current_target_pos : Vector2
var points_amount : int
var dir : Vector2 = Vector2.ZERO
var waits : bool
var path_is_cycle : bool
var order = 1

func enter():
	await get_tree().physics_frame
	enemy.nav_agent.set_velocity(Vector2.ZERO)
	enemy.intended_velocity = Vector2.ZERO
	path_is_cycle = enemy.path.cycle
	path_array = enemy.path.path_data
	points_amount = len(path_array)
	player = get_tree().get_first_node_in_group("player")
	get_next_point()
	
func exit():
	waits = false
	timer.stop()
	
func update(_delta : float):
	pass
	
func physics_update(_delta : float):
	if waits:
		enemy.intended_velocity = Vector2.ZERO
	elif enemy.global_position.distance_to(current_target_pos) < 1:
		if !path_array[current_point].wait_point:
			get_next_point()
		else:
			timer.wait_time = path_array[current_point].wait_time
			timer.start()
			waits = true
	else:
		dir = enemy.global_position.direction_to(current_target_pos)
		print_debug(dir * enemy.walking_speed)
		enemy.intended_velocity = dir * enemy.walking_speed

func get_next_point():
	if path_is_cycle:
		if current_point == points_amount - 1:
			current_point = 0
		else:
			current_point += 1
	else:
		current_point += order
		if current_point == points_amount or current_point == -1:
			order *= -1
			current_point += order * 2
			
	current_target_pos = path_array[current_point].position


func _on_wait_timer_timeout():
	waits = false
	get_next_point()
