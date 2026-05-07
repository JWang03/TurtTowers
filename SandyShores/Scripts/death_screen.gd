extends Control

@onready var loss_condition = get_node("../HUD/LossConditions")
@onready var starter = get_tree().current_scene.find_child("PlayButton", true, false)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if loss_condition.is_alive(loss_condition.lives) == false:
		visible = true
		starter.playing = false
