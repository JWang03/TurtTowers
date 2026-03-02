extends TileMapLayer

@export var tower_scene: PackedScene = preload("res://Towers.tscn")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Mouse global -> local
		var mouse_local_pos: Vector2 = to_local(event.position)

		# Local -> cell coords
		var cell: Vector2i = local_to_map(mouse_local_pos)

		# Cell -> local position of the cell's top-left (or origin point)
		var cell_local_origin: Vector2 = map_to_local(cell)

		# Center of the cell (in local space)
		# For a standard rectangular tilemap, tile_set.tile_size is the correct offset.
		var tile_size: Vector2 = Vector2(tile_set.tile_size)
		var spawn_local_pos: Vector2 = cell_local_origin + (tile_size * 0.5)

		# Spawn tower as a child of the same parent as the tilemap (so it doesn't get "tilemap-transformed" weirdly)
		var tower := tower_scene.instantiate() as Node2D
		get_parent().add_child(tower)

		# Convert local -> global for correct placement in the scene
		tower.global_position = to_global(spawn_local_pos)
		
		

		print("Placed tower at cell: ", cell, " world pos: ", tower.global_position)
