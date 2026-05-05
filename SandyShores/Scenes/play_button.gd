extends Button

@export var playing := false
@export var play_texture: Texture2D
@export var pause_texture: Texture2D

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pressed.connect(_on_button_pressed)
	_update_icons()

func _on_button_pressed():
	playing = !playing
	release_focus()
	_update_icons()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		_on_button_pressed()

func _update_icons():
	if play_texture and pause_texture:
		texture_normal = pause_texture if playing else play_texture
	else:
		push_warning("PlayButton: play_texture or pause_texture is not assigned.")
