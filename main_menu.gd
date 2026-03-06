extends Control

# --- VARIABLES ---
# Grabs the ID for Godot's main audio channel
var master_bus = AudioServer.get_bus_index("Master")

# Grabs references to your UI nodes
@onready var overlay = $CanvasLayer
@onready var menu_panel = $CanvasLayer/SettingsMenu
@onready var darkener = $CanvasLayer/Darkener


# --- BUILT-IN FUNCTIONS ---
func _ready():
	# Keep the settings menu hidden on start
	overlay.hide()


# --- SIGNAL FUNCTIONS ---
func _on_settings_pressed():
	# 1. Show the layer
	overlay.show()
	
	# 2. Prepare the animation state
	# Set pivot to center so it grows from the middle, not the corner
	menu_panel.pivot_offset = menu_panel.size / 2
	menu_panel.scale = Vector2.ZERO # Start tiny
	darkener.modulate.a = 0         # Start transparent
	
	# 3. Create the "Pop" animation
	var tween = create_tween().set_parallel(true)
	
	# Fade the dark background in
	tween.tween_property(darkener, "modulate:a", 1.0, 0.2)
	
	# "Pop" the menu up with a slight bounce (TRANS_BACK)
	tween.tween_property(menu_panel, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _on_button_pressed() -> void:
	# This is your "Back to Menu" button!
	var tween = create_tween().set_parallel(true)
	
	# Fade out the dark background
	tween.tween_property(darkener, "modulate:a", 0.0, 0.2)
	
	# Shrink the menu back to zero with a "suck in" effect (EASE_IN)
	tween.tween_property(menu_panel, "scale", Vector2.ZERO, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
	
	# Wait for the animations to finish, THEN hide the CanvasLayer entirely
	tween.chain().tween_callback(overlay.hide)

func _on_h_slider_value_changed(value: float) -> void:
	# Convert the 0.0-1.0 slider value to Decibels, and apply it to the Master Bus
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	
	# Completely mute the audio if the slider is dragged all the way down
	AudioServer.set_bus_mute(master_bus, value < 0.05)


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			print("Colorblind mode OFF")
			# Code to turn off filters goes here
		1:
			print("Protanopia selected")
			# Code to apply Red-Blind filter goes here
		2:
			print("Deuteranopia selected")
			# Code to apply Green-Blind filter goes here
		3:
			print("Tritanopia selected")
			# Code to apply Blue-Blind filter goes here
