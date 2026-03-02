extends TileMapLayer

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			
			var mouse_global_pos = event.position
			var mouse_local_pos = to_local(mouse_global_pos)
			var cell = local_to_map(mouse_local_pos)
			
			print("Clicked cell: ", cell)
