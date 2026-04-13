extends TextureButton

@export var playing: bool = false

func _ready():
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	playing = !playing
