extends Node3D
class_name InfoEnvironmetFlatBlack

func _ready() -> void:
	var world_env = WorldEnvironment.new()
	world_env.environment = load("res://Engine/Environments/BlackFlatEnvironment.tres")
	add_child(world_env)
