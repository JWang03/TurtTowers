extends Node2D

@export var speed := 100.0

func _process(delta):
	var follow = get_parent()
	if follow is PathFollow2D:
		follow.progress += speed * delta
