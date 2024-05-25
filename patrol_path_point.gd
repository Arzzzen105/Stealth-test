@tool
extends Resource
class_name PatrolPathPoint

@export var position : Vector2i = Vector2i.ZERO
@export var wait_point : bool = false:
	set(value):
		wait_point = value
		notify_property_list_changed()
		
var wait_time : float = 0

func _get_property_list() -> Array[Dictionary]:
	var properties : Array[Dictionary]
	
	if wait_point:
		properties.append({
			"name" : "wait_time",
			"type" : TYPE_FLOAT,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_RANGE,
			"hint_string" : "0, 5"
		})
	
	return properties
	
