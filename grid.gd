extends TileMapLayer

@export var tower_container: Node2D
@onready var build_manager = get_node("/root/Game/BuildManager")

var occupied_cells := {}

func _ready() -> void:
	visible = false
	build_manager.selection_changed.connect(_on_selection_changed)

func _on_selection_changed(selected_scene) -> void:
	visible = selected_scene != null
	print("grid visible: ", visible)

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

		if tower is Node2D:
			tower_container.add_child(tower)
			tower.position = spawn_pos
			occupied_cells[cell] = true
			print("tower placed at cell ", cell)
			build_manager.clear()
		else:
			print("selected scene is not a Node2D")
