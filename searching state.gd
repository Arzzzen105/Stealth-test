extends State

@export var enemy : CharacterBody2D

@onready var timer = $"wait timer"

var player : CharacterBody2D
var pathfinder : NavigationAgent2D
var dir : Vector2 = Vector2.ZERO
var points_to_check_left : int
var waits : bool

func enter():
	points_to_check_left = enemy.baked_points_amount
	timer.wait_time = enemy.baked_point_wait_time
	player = get_tree().get_first_node_in_group("player")
	pathfinder = enemy.nav_agent
	waits = true
	timer.start()
	
func exit():
	timer.stop()
	
func update(_delta : float):
	pass
	
func physics_update(_delta : float):
	
	if waits:
		enemy.intended_velocity = Vector2.ZERO
		return
		
	dir = enemy.global_position.direction_to(pathfinder.get_next_path_position()).normalized()
	enemy.intended_velocity = dir * enemy.searching_speed
	
	if enemy.global_position.distance_to(pathfinder.target_position) < 9:
		points_to_check_left -= 1
		waits = true
		timer.start()
	
func rand_target_position() -> Vector2:
	var result : Vector2
	var distance_between_player
	var direction_to_player
	var random_point_on_line 
	var random_point_in_range 
	while true: 
		distance_between_player = enemy.global_position.distance_to(player.global_position)
		direction_to_player = enemy.global_position.direction_to(player.global_position)
		random_point_on_line = enemy.global_position + Vector2(distance_between_player, 0).rotated(direction_to_player.angle()) * randf_range(0.3, 1.0)
		random_point_in_range = (random_point_on_line + Vector2(enemy.random_point_radius, 0).rotated(randf_range(0.0, PI * 2)) * randf_range(0.1, 1.0)).clamp(Vector2(0, 0), Vector2(576, 320))
		
		var params = PhysicsPointQueryParameters2D.new()
		params.position = random_point_in_range
		params.collision_mask = enemy.collision_mask
		
		if not enemy.get_world_2d().direct_space_state.intersect_point(params):
			break
			
			
	result = random_point_in_range
	
	return result


func _on_wait_timer_timeout():
	if points_to_check_left < 1:
			transitioned.emit(self, "back to patrolling state")
			waits = true
			return
	pathfinder.target_position = rand_target_position()
	waits = false
