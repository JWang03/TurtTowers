extends Node2D
@onready var upgrade_panel = get_node("root/Game/UI/UpgradePanel") # adjust to your actual path

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var space = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = get_global_mouse_position()
		var results = space.intersect_point(query)
		
		for result in results:
			var body = result.collider
			if body.has_method("apply_upgrade"):
				upgrade_panel.show_for(body)
				return
		
		upgrade_panel.visible = false
