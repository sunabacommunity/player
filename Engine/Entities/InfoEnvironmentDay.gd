extends Node3D
class_name InfoEnvironmetDay

func _ready() -> void:
	var world_env = WorldEnvironment.new()
	world_env.environment = load("res://Engine/Environments/DayEnvironment.tres")
	add_child(world_env)
