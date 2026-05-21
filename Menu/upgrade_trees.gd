extends CanvasLayer

var group = ButtonGroup.new()

const TOWER_SCENES_BY_MENU_NAME := {
	"TNTurt": "res://Towers/bomber_tower.tscn",
	"Fighturt Jet": "res://Towers/Turt-22.tscn",
	"The Lieturtant": "res://Towers/bullet_tower.tscn",
	"Flameturter": "res://Towers/flamethrower_tower.tscn",
	"Graviturt": "res://Towers/blackhole_tower.tscn",
	"Mad Scienturt": "res://Towers/electric_tower.tscn",
	"Turtosaurus Rex": "res://Towers/godzilla_tower.tscn",
	"Holy Crusaturt": "res://Towers/holy_crusader.tscn",
	"Shell Facturtory": "res://Towers/turt_factory.tscn",
	"Turt Town": "res://Towers/turttown.tscn",
	"Turt Sahur": "res://Towers/turttttt.tscn",
}

# Visual-only metadata. Branch names, upgrade names, and costs are read from
# each tower scene's script through its `upgrades` dictionary.
var upgrade_visual_data = {
	"TNTurt": {
		"left": {
			"upgrades": [
				{"icon": "💣", "desc": "Fires two bombs at once."},
				{"icon": "💣💣", "desc": "Fires three bombs at once."},
				{"icon": "💣💣💣", "desc": "Fires four bombs at once."},
			]
		},
		"right": {
			"upgrades": [
				{"icon": "🔥", "desc": "Doubles the fire rate."},
				{"icon": "🎯", "desc": "Doubles the detection range."},
				{"icon": "🚀", "desc": "Upgrades bombs to homing missiles."},
			]
		}
	},
	"Fighturt Jet": {
		"left": {
			"upgrades": [
				{"icon": "💥", "desc": "Widens the firing arc and increases projectile count to 8."},
				{"icon": "🌎", "desc": "Fires a 180-degree burst of 12 projectiles."},
				{"icon": "🪐", "desc": "Fires a massive 360-degree ring of 24 projectiles."},
			]
		},
		"right": {
			"upgrades": [
				{"icon": "⚡", "desc": "Tightens the spread and doubles the firing speed."},
				{"icon": "💥", "desc": "Doubles bullet damage and focuses the stream further."},
				{"icon": "🎯", "desc": "Condenses fire into a single high-damage bolt with extreme fire rate."},
			]
		}
	},
	"The Lieturtant": {
		"left": {
			"upgrades": [
				{"icon": "⚡", "desc": "Increases fire rate by 20%."},
				{"icon": "⚡⚡", "desc": "Further increases fire rate."},
				{"icon": "🔫🔫", "desc": "Fires two bullets simultaneously."},
			]
		},
		"right": {
			"upgrades": [
				{"icon": "🎯", "desc": "Extends detection range by 50%."},
				{"icon": "💥", "desc": "Bullets deal 5x damage."},
				{"icon": "🏹", "desc": "Bullets track targets. Massive damage & range boost."},
			]
		}
	},
	"Flameturter": {
		"left": {
			"upgrades": [
				{"icon": "🔥", "desc": "Doubles damage per tick."},
				{"icon": "🔥", "desc": "Fire area grows 50% larger."},
				{"icon": "💀", "desc": "Burning enemies spread fire on death."},
			]
		},
		"right": {
			"upgrades": [
				{"icon": "🐢", "desc": "Flames slow enemies to 60% speed."},
				{"icon": "🛡️", "desc": "Burning enemies take 30% more damage."},
				{"icon": "☄️", "desc": "Enemies ignite and keep burning after leaving range."},
			]
		}
	},
	"Graviturt": {
		"left": {
			"upgrades": [
				{"icon": "🌀🌀", "desc": "Spawns 2 black holes per shot."},
				{"icon": "🌀🌀🌀", "desc": "Spawns 3 black holes per shot."},
				{"icon": "♾️🌀", "desc": "Spawns 5 holes and fires 25% faster."},
			]
		},
		"right": {
			"upgrades": [
				{"icon": "🌌", "desc": "Black holes pull enemies much harder."},
				{"icon": "⏳", "desc": "Black holes last twice as long."},
				{"icon": "⚫", "desc": "Massive pull strength, size, and duration."},
			]
		}
	},
	"Mad Scienturt": {
		"left": {
			"upgrades": [
				{"icon": "⚡", "desc": "Lightning jumps further between enemies."},
				{"icon": "⚡⚡", "desc": "Attack cooldown cut in half."},
				{"icon": "💫⚡", "desc": "Lightning chain reaches 20 enemies."},
			]
		},
		"right": {
			"upgrades": [
				{"icon": "💥🧪", "desc": "Nearby towers deal double damage."},
				{"icon": "💨🧪", "desc": "Nearby towers shoot twice as fast."},
				{"icon": "❤️", "desc": "Synthesizes 100 extra lives."},
			]
		}
	},
	"Turtosaurus Rex": {
		"left": {
			"upgrades": [
				{"icon": "↔🦖", "desc": "Beam widens and deals 50% more damage."},
				{"icon": "↔↔🦖", "desc": "Beam widens further, more damage."},
				{"icon": "🦖⚡⚡", "desc": "Fires a second beam at another target."},
			]
		},
		"right": {
			"upgrades": [
				{"icon": "⚡", "desc": "Doubles beam damage."},
				{"icon": "☢️", "desc": "Doubles beam damage again."},
				{"icon": "💥", "desc": "Final doubling — maximum destruction."},
			]
		}
	},
	"Holy Crusaturt": {
		"left": {
			"upgrades": [
				{"icon": "💨", "desc": "Smites 33% faster."},
				{"icon": "🎯", "desc": "Detection range grows by 50%."},
				{"icon": "⚡", "desc": "Attack speed doubled."},
			]
		},
		"right": {
			"upgrades": [
				{"icon": "🌟", "desc": "Beam damage doubled."},
				{"icon": "💥🌟", "desc": "Beam damage doubled again."},
				{"icon": "👁️", "desc": "Beams now target the furthest enemy."},
			]
		}
	},
	"Shell Facturtory": {
		"left": {
			"upgrades": [
				{"icon": "💨🐢", "desc": "Spawns turts 40% faster."},
				{"icon": "🐢🐢", "desc": "Spawns two turts at once."},
				{"icon": "♾️🐢", "desc": "Extreme spawn speed with smaller turts."},
			]
		},
		"right": {
			"upgrades": [
				{"icon": "🛡️", "desc": "Turts have 3 HP and deal more damage."},
				{"icon": "💥", "desc": "Turts explode on death."},
				{"icon": "💪", "desc": "Spawns one giant turt with 10 HP and massive damage."},
			]
		}
	},
	"Turt Town": {
		"left": {
			"upgrades": [
				{"icon": "♜", "desc": "Spawns a mini turret nearby."},
				{"icon": "👥", "desc": "Spawns a second mini turret."},
				{"icon": "🏰", "desc": "Turrets shoot twice as fast. Buff radius doubled."},
			]
		},
		"right": {
			"upgrades": [
				{"icon": "💰", "desc": "Earns 20 shrimp every 8 seconds."},
				{"icon": "💰🛣️", "desc": "Earns 30 shrimp every 5 seconds."},
				{"icon": "💰🏘️", "desc": "Earns 50 shrimp every 3 seconds. Instant +300."},
			]
		}
	},
	"Turt Sahur": {
		"left": {
			"upgrades": [
				{"icon": "👅", "desc": "Attack speed doubled."},
				{"icon": "👅👅", "desc": "Detection range grows 50%."},
				{"icon": "👅👅👅", "desc": "Attack speed doubled again."},
			]
		},
		"right": {
			"upgrades": [
				{"icon": "🐌", "desc": "Slow effect doubled in strength."},
				{"icon": "🐌🐌", "desc": "Slows up to 3 enemies at once."},
				{"icon": "🐌🐌🐌", "desc": "Slows up to 6 enemies at once."},
			]
		}
	},
}

var desc_text_label: Label
var desc_price_label: Label
var desc_tween: Tween
var hidden_y: float
var shown_y: float
var desc_box: Button

func _ready() -> void:
	desc_box = $DescBox
	_setup_desc_box()
	await get_tree().process_frame
	var vbox = desc_box.get_child(0)
	vbox.position = Vector2(0, 10)
	vbox.size = desc_box.size
	vbox.custom_minimum_size = desc_box.size
	shown_y = desc_box.position.y
	hidden_y = shown_y - desc_box.size.y
	desc_box.pivot_offset = Vector2(desc_box.size.x / 2, 0)
	desc_box.position.y = hidden_y
	desc_box.modulate.a = 0.0

func load_tower_data(tower_name: String) -> void:
	var live_data := _get_live_tower_data(tower_name)
	if live_data.is_empty():
		reset_upgrades()
		return

	var visual_data = upgrade_visual_data.get(tower_name, {})
	if visual_data.is_empty() and upgrade_visual_data.has(live_data.get("tower_name", "")):
		visual_data = upgrade_visual_data[live_data["tower_name"]]

	var data := _merge_live_and_visual_data(live_data, visual_data)
	$LeftPathLabel.text = str(data["left"]["path_name"]).to_upper()
	$RightPathLabel.text = str(data["right"]["path_name"]).to_upper()
	group = ButtonGroup.new()
	_setup_path($LeftPath, data["left"]["upgrades"])
	_setup_path($RightPath, data["right"]["upgrades"])

func _get_live_tower_data(menu_tower_name: String) -> Dictionary:
	var scene_path = TOWER_SCENES_BY_MENU_NAME.get(menu_tower_name, "")
	if scene_path == "":
		return {}

	var packed_scene := load(scene_path)
	if not (packed_scene is PackedScene):
		return {}

	var tower = packed_scene.instantiate()
	var live_data := {}
	if "upgrades" in tower:
		live_data["upgrades"] = tower.get("upgrades")
	if "tower_name" in tower:
		live_data["tower_name"] = tower.get("tower_name")
	tower.free()

	if not live_data.has("upgrades"):
		return {}

	return live_data

func _merge_live_and_visual_data(live_data: Dictionary, visual_data: Dictionary) -> Dictionary:
	var live_upgrades: Dictionary = live_data["upgrades"]
	var merged := {
		"left": _merge_branch_data(live_upgrades.get("left", {}), visual_data.get("left", {})),
		"right": _merge_branch_data(live_upgrades.get("right", {}), visual_data.get("right", {}))
	}
	return merged

func _merge_branch_data(live_branch: Dictionary, visual_branch: Dictionary) -> Dictionary:
	var live_tiers: Array = live_branch.get("tiers", [])
	var visual_tiers: Array = visual_branch.get("upgrades", [])
	var merged_tiers := []

	for i in range(live_tiers.size()):
		var live_tier: Dictionary = live_tiers[i]
		var visual_tier: Dictionary = visual_tiers[i] if i < visual_tiers.size() else {}
		merged_tiers.append({
			"name": live_tier.get("label", ""),
			"price": live_tier.get("cost", 0),
			"icon": visual_tier.get("icon", ""),
			"desc": visual_tier.get("desc", "")
		})

	return {
		"path_name": live_branch.get("name", ""),
		"upgrades": merged_tiers
	}

func reset_upgrades() -> void:
	$LeftPathLabel.text = ""
	$RightPathLabel.text = ""
	if desc_tween:
		desc_tween.kill()
	if desc_box:
		desc_box.position.y = hidden_y
		desc_box.modulate.a = 0.0
	for path in [$LeftPath, $RightPath]:
		for button in path.get_children():
			button.button_pressed = false
			for child in button.get_children():
				child.queue_free()

func _setup_desc_box() -> void:
	desc_box.clip_contents = true
	desc_box.alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_box.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER

	var vbox = VBoxContainer.new()
	vbox.position = Vector2.ZERO
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	desc_box.add_child(vbox)

	desc_text_label = Label.new()
	desc_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	desc_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_text_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	desc_text_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(desc_text_label)

	desc_price_label = Label.new()
	desc_price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_price_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_price_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	desc_price_label.add_theme_font_size_override("font_size", 16)
	desc_price_label.add_theme_color_override("font_color", Color("#C8942A"))
	vbox.add_child(desc_price_label)

func _setup_path(path: VBoxContainer, data: Array) -> void:
	var buttons = path.get_children()
	for i in buttons.size():
		var button: Button = buttons[i]
		button.visible = i < data.size()
		button.toggle_mode = true
		button.button_group = group
		button.button_pressed = false

		for c in button.mouse_entered.get_connections():
			button.mouse_entered.disconnect(c["callable"])
		for c in button.mouse_exited.get_connections():
			button.mouse_exited.disconnect(c["callable"])
		for c in button.toggled.get_connections():
			button.toggled.disconnect(c["callable"])

		for child in button.get_children():
			child.queue_free()

		if i >= data.size():
			continue

		var vbox = VBoxContainer.new()
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		button.add_child(vbox)

		var icon = Label.new()
		icon.text = data[i]["icon"]
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.add_theme_font_size_override("font_size", 50)
		vbox.add_child(icon)

		var label = Label.new()
		label.text = data[i]["name"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 24)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(label)

		var captured_data = data[i]
		button.mouse_entered.connect(_show_desc.bind(captured_data))
		button.mouse_exited.connect(_on_mouse_exited.bind(button))
		button.toggled.connect(_on_button_toggled.bind(captured_data))

func _show_desc(data: Dictionary) -> void:
	desc_text_label.text = data["desc"]
	desc_price_label.text = "🦐" + str(data["price"])
	_animate_desc(true)

func _hide_desc() -> void:
	_animate_desc(false)

func _on_mouse_exited(button: Button) -> void:
	if not button.button_pressed:
		_hide_desc()

func _on_button_toggled(pressed: bool, data: Dictionary) -> void:
	if pressed:
		_show_desc(data)
	else:
		_hide_desc()

func _animate_desc(show: bool) -> void:
	if not is_inside_tree():
		return
	if desc_tween:
		desc_tween.kill()
	desc_tween = create_tween().set_parallel(true)
	if show:
		desc_tween.tween_property(desc_box, "position:y", shown_y, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		desc_tween.tween_property(desc_box, "modulate:a", 1.0, 0.15)
	else:
		desc_tween.tween_property(desc_box, "position:y", hidden_y, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
		desc_tween.tween_property(desc_box, "modulate:a", 0.0, 0.12)
