extends CharacterBody2D
class_name PatrolEnemy

@onready var sprite = $sprite
@onready var sight_area = $"sight area"
@onready var nav_agent : NavigationAgent2D = $pathfinder
@onready var state_machine : StateMachine = $"state machine"
@onready var patrol_state = $"state machine/patrol state"
@onready var chase_state = $"state machine/chase state"

@export_category("Enemy")

@export_group("Sight")
@export var sight_angle_degrees : int = 135
@export var distance : int = 128
@export var rotation_speed : float = 5.0

@export_group("Patrolling state")
@export var path : PatrolPath
@export var walking_speed : int = 24
@export var patrol_colors : EnemyColorData

@export_group("Chasing state")
@export var running_speed : int = 32
@export var blind_chasing_time : float = 3.0
@export var chase_colors : EnemyColorData

@export_group("Searching state")
@export var searching_speed : int = 24
@export var baked_points_amount : int = 3
@export var baked_point_wait_time : float = 3.0
@export var random_point_radius : int = 128
@export var search_colors : EnemyColorData

var sees_player : bool = false
var intended_velocity : Vector2 = Vector2.ZERO

func _ready():
	nav_agent.max_speed = running_speed
	sight_area.init(deg_to_rad(sight_angle_degrees), distance)
	queue_redraw()

func _process(delta):
	sight_area.update()

func _physics_process(delta):
	sight_area.physics_update()
	
	if state_machine.current_state.name != "patrol state":
		nav_agent.set_velocity(intended_velocity)
	else:
		#print_debug(intended_velocity)
		_on_pathfinder_velocity_computed(intended_velocity)
	
	if intended_velocity:
		rotation = lerp_angle(rotation, intended_velocity.angle(), rotation_speed / 100)
		
	if state_machine.current_state.name != "chase state":
		for entity in sight_area.get_spotted_entities():
			if entity.is_in_group("enemy"):
				if entity.state_machine.current_state.name == "chase state" and entity.sees_player:
					state_machine.current_state.transitioned.emit(state_machine.current_state, "chase state")

func _on_sight_area_entity_entered(entity):
	if entity.is_in_group("player"):
		sees_player = true
		tell_all_achieveble_enemies_about_player()
		state_machine.current_state.transitioned.emit(state_machine.current_state, "chase state")
	if entity.is_in_group("enemy"):
		if state_machine.current_state.name == "chase state" and sees_player:
			if entity.state_machine.current_state.name != "chase state":
				tell_another_enemy_about_player(entity)
		if entity.state_machine.current_state.name == "chase state" and entity.sees_player:
			state_machine.current_state.transitioned.emit(state_machine.current_state, "chase state")

func _on_sight_area_entity_exited(entity):
	if entity.is_in_group("player"):
		sees_player = false

func tell_another_enemy_about_player(another_enemy : PatrolEnemy):
	another_enemy.state_machine.current_state.transitioned.emit(another_enemy.state_machine.current_state, "chase state")

func _on_pathfinder_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()

func tell_all_achieveble_enemies_about_player():
	for entity in sight_area.get_spotted_entities():
		if entity.is_in_group("enemy"):
			if entity.state_machine.current_state.name != "chase state":
				tell_another_enemy_about_player(entity)

func sees_another_chasing_enemy() -> bool:
	for entity in sight_area.get_spotted_entities():
		if entity.is_in_group("enemy"):
			if entity.state_machine.current_state.name == "chase state" and entity.sees_player:
				return true
	return false

func change_colors(colors_data : EnemyColorData):
	sprite.color = colors_data.enemy_color
	sprite.edge.default_color = colors_data.enemy_edge
	sight_area.polygon.color = colors_data.sight_area_color
	sight_area.polygon_edge.default_color = colors_data.sight_area_edge
