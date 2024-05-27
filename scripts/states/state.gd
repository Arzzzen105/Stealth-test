## Scene for creating own states for State Machine

extends Node
class_name State

signal transitioned(previous_state, new_state_name)

func enter():
	pass
	
func exit():
	pass
	
func update(_delta : float):
	pass
	
func physics_update(_delta : float):
	pass
