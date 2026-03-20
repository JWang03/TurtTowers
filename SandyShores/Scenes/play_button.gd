extends TextureButton

@export var play_texture: Texture2D
@export var pause_texture: Texture2D
@export var playing := false

func _ready():
	pressed.connect(_on_button_pressed)
	_update_texture()

func _on_button_pressed():
	playing = !playing
	release_focus()
	_update_texture()
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		_on_button_pressed()
func _update_texture():
	if playing:
		texture_normal = pause_texture
	else:
		texture_normal = play_texture
