extends Node2D

@export_group("Paths")
@export_color_no_alpha var path_color
@export_range(0.0, 5.0) var path_link_width : float = 1.0
@export_range(0.0, 10.0) var waypoint_radius : float = 2.0
@export_range(0.0, 10.0) var waitpoint_radius : float = 3.0

var enemies : Array[Node]

func _ready():
	enemies = get_tree().get_nodes_in_group("enemy")

func _draw():
	for enemy in enemies:
		var point_A : PatrolPathPoint; var point_B : PatrolPathPoint
		point_A = enemy.path.path_data[0]
		var skip : bool = true
		for point : PatrolPathPoint in enemy.path.path_data:
			if skip:
				skip = false
				continue
			point_B = point
			draw_line(point_A.position, point_B.position, path_color, path_link_width)
			draw_circle(point_A.position, waitpoint_radius if point_A.wait_point else waypoint_radius, path_color)
			point_A = point_B
		draw_circle(point_A.position, waitpoint_radius if point_A.wait_point else waypoint_radius, path_color)
		if enemy.path.cycle:
			draw_line(enemy.path.path_data[0].position, point_B.position, path_color, path_link_width)
