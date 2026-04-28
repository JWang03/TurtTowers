extends Button

func _on_pressed():
	# Call the Autoload node by the exact name you gave it in Project Settings
	GlobalSettings.open_settings()
