extends State

@export var enemy : CharacterBody2D
@export var patrol_state : State

var pathfinder : NavigationAgent2D

var target_pos : Vector2 = Vector2.ZERO
var dir : Vector2 = Vector2.ZERO

func enter():
	enemy.change_colors(enemy.patrol_colors)
	target_pos = patrol_state.path_array[patrol_state.current_point].position
	pathfinder = enemy.nav_agent
	find_path()
	
func exit():
	pass
	
func update(_delta : float):
	pass
	
func physics_update(_delta : float):
	var next_pos = pathfinder.get_next_path_position()
	dir = enemy.global_position.direction_to(next_pos)
	enemy.intended_velocity = dir * enemy.walking_speed
	if pathfinder.distance_to_target() < 4:
		transitioned.emit(self, "patrol state")
	
func find_path():
	pathfinder.target_position = target_pos
