extends Area2D

@onready var polygon = $"visual area"
@onready var hitbox = $hitbox
@onready var polygon_edge = $"area edge"
var space_state : PhysicsDirectSpaceState2D

# @export_category("AreaOfSight")

## Export here a parent of the area (like enemies).
@export var parent_body : Node2D 

## Export here a parent's AreaOfSightAgent if there's one.
@export var parent_agent : Area2D

@export_group("Size")
## An agle that desribes the width of AreaOfSight.
@export var sight_angle_degrees : int = 45
## A variable that describes how far the object can see.
@export var radius : int = 32
## A variable that descrides the amount of rays to draw the area.
@export var step_angle = PI/180

@export_group("Collisions")
## Collision layers the AreaOfSight will collide. Usually walls or obstacles.
@export_flags_2d_physics var sight_collision_mask = 4
## Collision layers of AreaOfSightAgents that the AreaOfSight will track. Usually a player or other enemies.
@export_flags_2d_physics var tracked_objects_mask = 1

@export_group("Color")
@export var color : Color = Color(1, 0, 0, 0.5)
@export var gradient : GradientTexture1D
@export var show_edge : bool = false
@export var edge_color : Color = Color(1, 0.3, 0.237, 0.373)

var sight_angle_rad
var vision_polygon_points : PackedVector2Array = []
var agents_in_radius : Array[CollisionObject2D] = []
var spotted_entities : Array[CollisionObject2D] = []
var player : CharacterBody2D

signal entity_entered(entity : CollisionObject2D)
signal entity_exited(entity : CollisionObject2D)

func init(_sight_angle_rad, _radius):
	sight_angle_rad = _sight_angle_rad
	radius = _radius
	hitbox.shape.radius = radius
	collision_mask = tracked_objects_mask
	player = get_tree().get_first_node_in_group("player")
	set_color(color, gradient, edge_color)
	
	vision_polygon_points = get_polygon_points()

func update():
	redraw_polygon()
	if show_edge:
		redraw_polygon_edges()

func physics_update():
	vision_polygon_points = get_polygon_points()
	update_spotted_array()

func redraw_polygon():
	if vision_polygon_points:
		polygon.polygon = vision_polygon_points

func redraw_polygon_edges():
	if vision_polygon_points:
		polygon_edge.points = vision_polygon_points
	
func update_collision_polygon():
	if vision_polygon_points:
		hitbox.polygon = vision_polygon_points

func get_polygon_points():
	var new_polygon_points : PackedVector2Array = []
	
	if sight_angle_rad < 2 * PI:
		new_polygon_points.append(Vector2.ZERO)
		
	for i in range(int(sight_angle_rad / step_angle)):
		new_polygon_points.append(ray_to(Vector2(radius, 0).rotated(rotation + step_angle * i - sight_angle_rad / 2)))
	
	return new_polygon_points
		
func ray_to(to : Vector2) -> Vector2:
	
	var ray_params = PhysicsRayQueryParameters2D.create(to_global(position), to_global(to), sight_collision_mask)
	var ray_result = get_world_2d().direct_space_state.intersect_ray(ray_params)
	var result : Vector2 = Vector2.ZERO
	if ray_result:
		result = to_local(ray_result.position)
	else:
		result = to
	return result

func update_spotted_array():
	for agent in agents_in_radius:
		var agent_pos : Vector2 = to_local(agent.global_position)
		var see_agent : bool = false
		var entity = agent.parent_node
		if Geometry2D.is_point_in_polygon(agent_pos, vision_polygon_points):
			see_agent = true
		for i in range(agent.baked_points_amount):
			if not see_agent and Geometry2D.is_point_in_polygon(agent_pos + agent.baked_points[i], vision_polygon_points):
				see_agent = true
			
		if see_agent and not entity in spotted_entities:
			#print_debug(parent_body.name, " sees ", entity.name)
			spotted_entities.append(entity)
			entity_entered.emit(entity)
		elif not see_agent and entity in spotted_entities:
			#print_debug(parent_body.name, " does not see ", entity.name, " anymore")
			spotted_entities.erase(entity)
			entity_exited.emit(entity)


func _on_area_entered(area):
	if parent_agent:
		if area == parent_agent:
			return
	if area.is_in_group("area of sight agent") and not area.parent_node in agents_in_radius:
		#print_debug(area.parent_node.name, " is in range of ", parent_body.name)
		agents_in_radius.append(area)


func _on_area_exited(area):
	if parent_agent:
		if area == parent_agent:
			return
	if area.is_in_group("area of sight agent") and area.parent_node in agents_in_radius:
		#print_debug(area.parent_node.name, " is not in range of ", parent_body.name)
		agents_in_radius.erase(area)

func set_color(_color : Color, _gradient : GradientTexture1D, _edge_color : Color):
	polygon.color = _color
	polygon.texture = _gradient
	polygon_edge.default_color = _edge_color

func get_spotted_entities():
	return spotted_entities
