extends CanvasLayer

var group = ButtonGroup.new()

var all_tower_data = {
	"TNTurt": {
		"left": {
			"path_name": "CLUSTER BOMBER",
			"upgrades": [
				{"name": "+1 Bomb", "icon": "💣", "desc": "Fires two bombs at once.", "price": 75},
				{"name": "+1 Bomb", "icon": "💣💣", "desc": "Fires three bombs at once.", "price": 150},
				{"name": "+1 Bomb", "icon": "💣💣💣", "desc": "Fires four bombs at once.", "price": 300},
			]
		},
		"right": {
			"path_name": "MISSILE MENACE",
			"upgrades": [
				{"name": "Faster Fire", "icon": "🔥", "desc": "Doubles the fire rate.", "price": 100},
				{"name": "Increased Range", "icon": "🎯", "desc": "Doubles the detection range.", "price": 200},
				{"name": "Homing Missiles", "icon": "🚀", "desc": "Upgrades bombs to homing missiles.", "price": 300},
			]
		}
	},
	"Fighturt Jet": {
		"left": {
			"path_name": "SPREAD",
			"upgrades": [
				{"name": "Wide Burst", "icon": "💥", "desc": "Widens the firing arc and increases projectile count to 8.", "price": 100},
				{"name": "Hemisphere Fire", "icon": "🌎", "desc": "Fires a 180-degree burst of 12 projectiles.", "price": 250},
				{"name": "Omnidirectional", "icon": "🪐", "desc": "Fires a massive 360-degree ring of 24 projectiles.", "price": 500},
			]
		},
		"right": {
			"path_name": "FOCUSED FIRE",
			"upgrades": [
				{"name": "Faster Shooting", "icon": "⚡", "desc": "Tightens the spread and doubles the firing speed.", "price": 75},
				{"name": "High Caliber", "icon": "💥", "desc": "Doubles bullet damage and focuses the stream further.", "price": 175},
				{"name": "Railgun Mode", "icon": "🎯", "desc": "Condenses fire into a single high-damage bolt with extreme fire rate.", "price": 500},
			]
		}
	},
	"The Lieturtant": {
		"left": {
			"path_name": "GUNNER",
			"upgrades": [
				{"name": "Faster Shooting", "icon": "⚡", "desc": "Increases fire rate by 20%.", "price": 75},
				{"name": "Faster Shooting 2", "icon": "⚡⚡", "desc": "Further increases fire rate.", "price": 150},
				{"name": "Double Shot", "icon": "🔫🔫", "desc": "Fires two bullets simultaneously.", "price": 300},
			]
		},
		"right": {
			"path_name": "MARKSMAN",
			"upgrades": [
				{"name": "Increased Range", "icon": "🎯", "desc": "Extends detection range by 50%.", "price": 100},
				{"name": "High Caliber", "icon": "💥", "desc": "Bullets deal 5x damage.", "price": 200},
				{"name": "Aimbot", "icon": "🏹", "desc": "Bullets track targets. Massive damage & range boost.", "price": 700},
			]
		}
	},
	"Flameturter": {
		"left": {
			"path_name": "INFERNO",
			"upgrades": [
				{"name": "Hotter Flames", "icon": "🔥", "desc": "Doubles damage per tick.", "price": 75},
				{"name": "Wider Spread", "icon": "🔥", "desc": "Fire area grows 50% larger.", "price": 150},
				{"name": "Napalm", "icon": "💀", "desc": "Burning enemies spread fire on death.", "price": 300},
			]
		},
		"right": {
			"path_name": "CROWD CONTROL",
			"upgrades": [
				{"name": "Scorched Earth", "icon": "🐢", "desc": "Flames slow enemies to 60% speed.", "price": 100},
				{"name": "Weaken", "icon": "🛡️", "desc": "Burning enemies take 30% more damage.", "price": 200},
				{"name": "Flashpoint", "icon": "☄️", "desc": "Enemies ignite and keep burning after leaving range.", "price": 700},
			]
		}
	},
	"Graviturt": {
		"left": {
			"path_name": "SCATTER",
			"upgrades": [
				{"name": "Twin Holes", "icon": "🌀🌀", "desc": "Spawns 2 black holes per shot.", "price": 100},
				{"name": "Triple Holes", "icon": "🌀🌀🌀", "desc": "Spawns 3 black holes per shot.", "price": 200},
				{"name": "Hole Barrage", "icon": "♾️🌀", "desc": "Spawns 5 holes and fires 25% faster.", "price": 400},
			]
		},
		"right": {
			"path_name": "SINGULARITY",
			"upgrades": [
				{"name": "Stronger Pull", "icon": "🌌", "desc": "Black holes pull enemies much harder.", "price": 100},
				{"name": "Extended Duration", "icon": "⏳", "desc": "Black holes last twice as long.", "price": 250},
				{"name": "Event Horizon", "icon": "⚫", "desc": "Massive pull strength, size, and duration.", "price": 600},
			]
		}
	},
	"Mad Scienturt": {
		"left": {
			"path_name": "THE PHYSICIST",
			"upgrades": [
				{"name": "Farther Chain", "icon": "⚡", "desc": "Lightning jumps further between enemies.", "price": 75},
				{"name": "Faster Shooting", "icon": "⚡⚡", "desc": "Attack cooldown cut in half.", "price": 150},
				{"name": "Farthest Chain", "icon": "💫⚡", "desc": "Lightning chain reaches 20 enemies.", "price": 300},
			]
		},
		"right": {
			"path_name": "THE CHEMIST",
			"upgrades": [
				{"name": "Damage Aura", "icon": "💥🧪", "desc": "Nearby towers deal double damage.", "price": 100},
				{"name": "Speed Aura", "icon": "💨🧪", "desc": "Nearby towers shoot twice as fast.", "price": 200},
				{"name": "Extra Lives", "icon": "❤️", "desc": "Synthesizes 100 extra lives.", "price": 700},
			]
		}
	},
	"Turtosaurus Rex": {
		"left": {
			"path_name": "TWIN PEAKS",
			"upgrades": [
				{"name": "Wider Beam", "icon": "↔🦖", "desc": "Beam widens and deals 50% more damage.", "price": 75},
				{"name": "Widest Beam", "icon": "↔↔🦖", "desc": "Beam widens further, more damage.", "price": 150},
				{"name": "Dual Beam", "icon": "🦖⚡⚡", "desc": "Fires a second beam at another target.", "price": 300},
			]
		},
		"right": {
			"path_name": "ATOMIC",
			"upgrades": [
				{"name": "Supercharged", "icon": "⚡", "desc": "Doubles beam damage.", "price": 100},
				{"name": "Critical Mass", "icon": "☢️", "desc": "Doubles beam damage again.", "price": 200},
				{"name": "Meltdown", "icon": "💥", "desc": "Final doubling — maximum destruction.", "price": 700},
			]
		}
	},
	"Holy Crusaturt": {
		"left": {
			"path_name": "RADIANT FURY",
			"upgrades": [
				{"name": "Faster Attacks", "icon": "💨", "desc": "Smites 33% faster.", "price": 75},
				{"name": "Increased Range", "icon": "🎯", "desc": "Detection range grows by 50%.", "price": 150},
				{"name": "Frenzy", "icon": "⚡", "desc": "Attack speed doubled.", "price": 300},
			]
		},
		"right": {
			"path_name": "DIVINE EYE",
			"upgrades": [
				{"name": "Stronger Beams", "icon": "🌟", "desc": "Beam damage doubled.", "price": 100},
				{"name": "Ultra Beams", "icon": "💥🌟", "desc": "Beam damage doubled again.", "price": 200},
				{"name": "Aim", "icon": "👁️", "desc": "Beams now target the furthest enemy.", "price": 700},
			]
		}
	},
	"Shell Facturtory": {
		"left": {
			"path_name": "ASSEMBLY LINE",
			"upgrades": [
				{"name": "Faster Belt", "icon": "💨🐢", "desc": "Spawns turts 40% faster.", "price": 75},
				{"name": "Double Line", "icon": "🐢🐢", "desc": "Spawns two turts at once.", "price": 175},
				{"name": "Mass Production", "icon": "♾️🐢", "desc": "Extreme spawn speed with smaller turts.", "price": 400},
			]
		},
		"right": {
			"path_name": "HEAVY SHELL",
			"upgrades": [
				{"name": "Reinforced Hull", "icon": "🛡️", "desc": "Turts have 3 HP and deal more damage.", "price": 100},
				{"name": "Explosive Shell", "icon": "💥", "desc": "Turts explode on death.", "price": 250},
				{"name": "Mega Turt", "icon": "💪", "desc": "Spawns one giant turt with 10 HP and massive damage.", "price": 600},
			]
		}
	},
	"Turt Town": {
		"left": {
			"path_name": "TURT-RETS",
			"upgrades": [
				{"name": "Watchtower", "icon": "♜", "desc": "Spawns a mini turret nearby.", "price": 150},
				{"name": "The Buddy System", "icon": "👥", "desc": "Spawns a second mini turret.", "price": 300},
				{"name": "Fortified", "icon": "🏰", "desc": "Turrets shoot twice as fast. Buff radius doubled.", "price": 600},
			]
		},
		"right": {
			"path_name": "ECONOMY",
			"upgrades": [
				{"name": "Tax Office", "icon": "💰", "desc": "Earns 20 shrimp every 8 seconds.", "price": 125},
				{"name": "Trade Routes", "icon": "💰🛣️", "desc": "Earns 30 shrimp every 5 seconds.", "price": 275},
				{"name": "Boom Town", "icon": "💰🏘️", "desc": "Earns 50 shrimp every 3 seconds. Instant +300.", "price": 650},
			]
		}
	},
	"Turt Sahur": {
		"left": {
			"path_name": "TUNG",
			"upgrades": [
				{"name": "Tung", "icon": "👅", "desc": "Attack speed doubled.", "price": 75},
				{"name": "Tung^2", "icon": "👅👅", "desc": "Detection range grows 50%.", "price": 150},
				{"name": "Tung^3", "icon": "👅👅👅", "desc": "Attack speed doubled again.", "price": 300},
			]
		},
		"right": {
			"path_name": "LARP",
			"upgrades": [
				{"name": "Larp", "icon": "🐌", "desc": "Slow effect doubled in strength.", "price": 100},
				{"name": "Larp^2", "icon": "🐌🐌", "desc": "Slows up to 3 enemies at once.", "price": 200},
				{"name": "Larp^3", "icon": "🐌🐌🐌", "desc": "Slows up to 6 enemies at once.", "price": 700},
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
	if not all_tower_data.has(tower_name):
		return
	var data = all_tower_data[tower_name]
	$LeftPathLabel.text = data["left"]["path_name"]
	$RightPathLabel.text = data["right"]["path_name"]
	group = ButtonGroup.new()
	_setup_path($LeftPath, data["left"]["upgrades"])
	_setup_path($RightPath, data["right"]["upgrades"])

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
