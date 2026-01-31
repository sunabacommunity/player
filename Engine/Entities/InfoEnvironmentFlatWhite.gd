extends Node3D
class_name InfoEnvironmetFlatWhite

func _ready() -> void:
	var world_env = WorldEnvironment.new()
	world_env.environment = load("res://Engine/Environments/WhiteFlatEnvironment.tres")
	add_child(world_env)
