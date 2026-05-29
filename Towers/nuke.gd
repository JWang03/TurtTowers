extends TowerBase

@export var nuke_damage: float = 1000.0
@export var blast_radius: float = 250.0
@export var fall_speed: float = 2.0
@onready var missile_sprite = $Sprite2D
@onready var explosion_ani = $MushroomCloud
@onready var crater_sprite = $Crater
var has_exploded: bool = false

func _ready():
	cost = 500
	super._ready()
	if explosion_ani:
		explosion_ani.hide()
	if crater_sprite:
		crater_sprite.hide()

func on_placed():
	cost = 0
	start_nuke_sequence()

func start_nuke_sequence():
	var target_pos = global_position
	global_position.y -= 1000
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, fall_speed)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_IN)
	tween.finished.connect(_on_impact)

func _on_impact():
	if has_exploded:
		return
	has_exploded = true
	remove_from_group("towers")
	if missile_sprite:
		missile_sprite.hide()
	if crater_sprite:
		crater_sprite.show()
	if explosion_ani:
		explosion_ani.show()
		explosion_ani.play("default")
		explosion_ani.animation_finished.connect(_on_explosion_finished)
	destroy_nearby_towers()
	damage_zombies()

func _on_explosion_finished():
	explosion_ani.hide()

func destroy_nearby_towers():
	var all_towers = get_tree().get_nodes_in_group("towers")
	var tile_size = 64

	for tower in all_towers:
		if tower == self:
			continue
		if global_position.distance_to(tower.global_position) < (tile_size * 1.5):
			# unregister tier 3s before destroying
			var tower_name = tower.get("tower_name")
			if tower_name:
				var left_level = tower.get("left_level")
				var right_level = tower.get("right_level")
				if left_level != null and left_level >= 3:
					UpgradeManager.unregister_tier3_left(tower_name)
				if right_level != null and right_level >= 3:
					UpgradeManager.unregister_tier3_right(tower_name)
			if tower.tilemap:
				tower.tilemap.unoccupy_cell(tower.occupied_cell)
			tower.queue_free()

func damage_zombies():
	var zombies = get_tree().get_nodes_in_group("zombies")
	for zombie in zombies:
		if global_position.distance_to(zombie.global_position) < blast_radius:
			if zombie.has_method("take_damage"):
				zombie.take_damage(nuke_damage)
