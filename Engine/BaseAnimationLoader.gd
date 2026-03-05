extends RefCounted

func loadAnimations(animPlayer: AnimationPlayer):
	var animations: AnimationLibrary = load("res://Engine/BaseAnimations.res")
	animPlayer.add_animation_library("Base", animations)
