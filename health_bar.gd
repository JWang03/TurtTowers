extends Node2D

@onready var fill = $Fill
@onready var background = $Background

func _ready():
	# sync bar_width to whatever the background actually is
	fill.size.x = background.size.x
	fill.position.x = background.position.x
	var w = background.size.x
	background.position.x = -w / 2.0
	fill.position.x = -w / 2.0
	fill.size.x = w  # start full

func update(current_hp: float, max_hp: float):
	var ratio = clamp(current_hp / max_hp, 0.0, 1.0)
	fill.size.x = background.size.x * ratio
	fill.color = Color.GRAY.lerp(Color.RED, ratio)
