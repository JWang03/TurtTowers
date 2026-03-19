extends Node2D

@export var speed := 100.0
@export var damage = 5
@onready var loss_conditions = get_node("/root/Game/UI/LossConditions")
func _process(delta):
	var follow = get_parent()
	if follow is PathFollow2D:
		follow.progress += speed * delta
	
		var path_length = follow.get_parent().curve.get_baked_length()
		if follow.progress >= path_length:
			follow.queue_free()
			loss_conditions.spend_lives(damage)
