extends Button

# Paths based on your uploaded scene tree
@onready var settings_layer = $"../../CanvasLayer"
@onready var anim_player = $"../../CanvasLayer/ColorRect/PanelContainer/AnimationPlayer"

func _on_pressed():
	# 1. Make the layer visible first
	settings_layer.show()
	# 2. Play the animation
	anim_player.play("popup")
