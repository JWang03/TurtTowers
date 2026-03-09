extends TileMapLayer

@export var tower_container: Node2D
@onready var build_manager = get_node("/root/Game/BuildManager")


var occupied_cells := {}
var ghost_tower: Node2D = null

func _ready() -> void:
	visible = false
	build_manager.selection_changed.connect(_on_selection_changed)

func _on_selection_changed(selected_scene) -> void:
	visible = selected_scene != null
	print("grid visible: ", visible)

	if ghost_tower:
		ghost_tower.queue_free()
		ghost_tower = null

	if selected_scene != null:
		var preview = selected_scene.instantiate()
		if preview is Node2D:
			ghost_tower = preview
			tower_container.add_child(ghost_tower)
			ghost_tower.modulate.a = 0.5
func _process(_delta: float) -> void:
	if ghost_tower == null:
		return

	if build_manager.selected_scene == null:
		return

	var mouse_local: Vector2 = get_local_mouse_position()
	var cell: Vector2i = local_to_map(mouse_local)

	var cell_local_center: Vector2 = map_to_local(cell)
	var cell_global_center: Vector2 = to_global(cell_local_center)
	var ghost_pos: Vector2 = tower_container.to_local(cell_global_center)

	ghost_tower.position = ghost_pos
func can_place_on_cell(cell: Vector2i) -> bool:
	var tile_data = get_cell_tile_data(cell)
	if tile_data == null:
		return false
	return tile_data.get_custom_data("placeable")
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("click detected by grid script")

		if build_manager.selected_scene == null:
			print("no tower selected")
			return

		var mouse_local: Vector2 = get_local_mouse_position()
		var cell: Vector2i = local_to_map(mouse_local)
		print("clicked cell: ", cell)

		if occupied_cells.has(cell):
			print("cell already occupied")
			return

		var cell_local_center: Vector2 = map_to_local(cell)
		var cell_global_center: Vector2 = to_global(cell_local_center)
		var spawn_pos: Vector2 = tower_container.to_local(cell_global_center)

		var tower = build_manager.selected_scene.instantiate()
		if can_place_on_cell(cell)==true:
			if tower is Node2D:
				tower_container.add_child(tower)
				tower.position = spawn_pos
				occupied_cells[cell] = true
				print("tower placed at cell ", cell)
				build_manager.clear()
		else:
			print("selected scene is not a Node2D")
