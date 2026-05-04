extends StaticBody2D
class_name TowerBase

enum TargetMode {FIRST, WEAKEST, STRONGEST, CLOSEST}

@export var target_priority: TargetMode = TargetMode.FIRST
@export var is_placed: bool = false 
@export var fire_rate: float = 1.0

@onready var starter = get_node_or_null("/root/Game/UI/Start_Pause/PlayButton")
@onready var detection_area = $Range

func _ready():
	add_to_group("towers")
	#make sure you add super.ready() to the ready function of all the towers plz

func get_best_target() -> Node2D:
	if not is_placed or (starter and !starter.playing):
		return null
		
	var targets = detection_area.get_overlapping_bodies().filter(func(b): 
		var is_stealth = b.is_stealth if "is_stealth" in b else false
		return b.is_in_group("zombies") and not is_stealth
)
	
	if targets.is_empty():
		return null

	match target_priority:
		TargetMode.FIRST:
			targets.sort_custom(func(a, b): 
				return (a.progress if "progress" in a else 0.0) > (b.progress if "progress" in b else 0.0))
		TargetMode.WEAKEST:
			targets.sort_custom(func(a, b): 
				return (a.health if "health" in a else 0) < (b.health if "health" in b else 0))
		TargetMode.STRONGEST:
			targets.sort_custom(func(a, b): 
				return (a.health if "health" in a else 0) > (b.health if "health" in b else 0))
		TargetMode.CLOSEST:
			targets.sort_custom(func(a, b): 
				return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	return targets[0]

func get_shield_provider(zombie):
	var protectors = get_tree().get_nodes_in_group("shield_mobs")
	for p in protectors:
		if is_instance_valid(p) and p.get("is_shield_active"):
			if p.global_position.distance_to(zombie.global_position) <= p.shield_radius:
				return p
	return null

func cycle_target_mode():
	var current_index = target_priority as int
	var next_index = (current_index + 1) % TargetMode.size()
	target_priority = next_index as TargetMode
	
	print("Tower mode changed to: ", TargetMode.keys()[target_priority])
	
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var ui_node = get_node_or_null("/root/Game/UI/tower_targeting")
			if ui_node:
				ui_node.set_selected_tower(self)
				
func set_target_priority(new_mode_index: int):
	target_priority = new_mode_index as TargetMode
	print(name, " changed mode to: ", target_priority)
