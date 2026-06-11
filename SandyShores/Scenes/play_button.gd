extends Button

# Default to false, but we will auto-correct this in _ready()
@export var playing := false

@onready var resume_icon = $Resume
@onready var pause_icon = $Pause

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
	if playing:
		resume_icon.hide()
		pause_icon.show()
	else:
		resume_icon.show()
		pause_icon.hide()
