extends Node3D
class_name InfoEnvironmetDreamy

func _ready() -> void:
	var world_env = WorldEnvironment.new()
	world_env.environment = load("res://Engine/Environments/DreamyEnvironment.tres")
	add_child(world_env)
