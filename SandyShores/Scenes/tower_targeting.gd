extends Button

var current_global_mode = 0

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	print("pressed")
	current_global_mode = (current_global_mode + 1) % 4
	get_tree().call_group("towers", "set_target_priority", current_global_mode)
	var mode_names = ["FIRST", "WEAKEST", "STRONGEST", "CLOSEST"]
	text = "Global Mode: " + mode_names[current_global_mode]
