extends Node3D
class_name InfoEnvironmetNight

func _ready() -> void:
	var world_env = WorldEnvironment.new()
	world_env.environment = load("res://Engine/Environments/GreyEnviroment.tres")
	add_child(world_env)
