extends State

@export var enemy : PatrolEnemy

var player : CharacterBody2D
var reason : String
var target_position : Vector2 = Vector2.ZERO
var pathfinder : NavigationAgent2D
var speed : int

func enter():
	player = get_tree().get_first_node_in_group("player")
	pathfinder = enemy.nav_agent
	
	await get_tree().physics_frame
	
	set_path()
	
func exit():
	pass
	
func update(_delta : float):
	pass
	
func physics_update(_delta : float):
	if reason in ["player"]:
		speed = enemy.running_speed
		
	var next_point = pathfinder.get_next_path_position()
	var direction = enemy.global_position.direction_to(next_point)
	
	enemy.intended_velocity = direction * speed
	
	if enemy.global_position.distance_to(pathfinder.target_position) < 5:
		if chasing_enemies_in_sight_area():
			pathfinder.target_position = player.global_position
		else:
			if reason in ["player"]:
				transitioned.emit(self, "searching state")

func set_path():
	pathfinder.target_position = target_position
	
func chasing_enemies_in_sight_area() -> bool:
	var entities = enemy.sight_area.get_spotted_entities()
	for entity in entities:
		if entity.is_in_group("enemy"):
			if entity.state_machine.current_state.name == "chase state" and entity.sees_player:
				return true
	return false
