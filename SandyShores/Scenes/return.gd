extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")
