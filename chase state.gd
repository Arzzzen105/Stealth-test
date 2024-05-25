extends State

@export var enemy : PatrolEnemy

@onready var update_path_timer = $"update path timer"
@onready var blind_chasing_timer = $"blind chasing timer"

var player : CharacterBody2D
var pathfinder : NavigationAgent2D
var dir : Vector2 = Vector2.ZERO
var can_blind_update : bool
var saw_player_during_blind_chasing : bool = true

func enter():
	can_blind_update = true
	saw_player_during_blind_chasing = true
	blind_chasing_timer.wait_time = enemy.blind_chasing_time
	player = get_tree().get_first_node_in_group("player")
	pathfinder = enemy.nav_agent
	update_path()
	update_path_timer.start()
	
func exit():
	update_path_timer.stop()
	blind_chasing_timer.stop()
	
func update(_delta : float):
	pass
	
func physics_update(_delta : float):
	var next_pos = pathfinder.get_next_path_position()
	var dir = enemy.global_position.direction_to(next_pos)
	
	enemy.intended_velocity = dir * enemy.running_speed
	
	if not enemy.sees_player and blind_chasing_timer.is_stopped() and saw_player_during_blind_chasing:
		saw_player_during_blind_chasing = false
		can_blind_update = true
		blind_chasing_timer.start()
	elif enemy.sees_player and not blind_chasing_timer.is_stopped():
		saw_player_during_blind_chasing = true
		can_blind_update = false
		blind_chasing_timer.stop()
		
	if enemy.global_position.distance_to(pathfinder.target_position) < 7 and not enemy.global_position.distance_to(player.global_position) < 24:
		transitioned.emit(self, "searching state")

func update_path():
	pathfinder.target_position = player.global_position

func _on_update_path_timer_timeout():
	if enemy.sees_player or can_blind_update or enemy.global_position.distance_to(player.global_position) < 24:
		update_path()

func _on_blind_chasing_timer_timeout():
	if enemy.sees_player:
		update_path()
	can_blind_update = false
