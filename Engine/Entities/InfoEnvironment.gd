extends Node3D
class_name InfoEnvironmet

func _ready() -> void:
	var world_env = WorldEnvironment.new()
	world_env.environment = load("res://Engine/Environments/new_environment.tres")
	add_child(world_env)
