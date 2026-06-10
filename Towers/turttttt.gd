extends TowerBase

const TOWER_FRAME_COLUMNS := 7
const TOWER_FRAME_ROWS := 2
const TOWER_FRAME_WIDTH := 134
const TOWER_FRAME_HEIGHT := 133
const TOWER_ANIMATION_NAME := &"attack"
const TOWER_ANIMATION_SPEED := 20.0
const UPGRADED_SPRITE_SCALE := Vector2(0.475, 0.475)
const TUNG_FRAMES_TEXTURE := preload("res://textures/Frames/tung_frames.png")
const LARP_FRAMES_TEXTURE := preload("res://textures/Frames/larp_frames.png")

@export var attack_damage: float = 5.0
@export var slow_factor: float = 0.2
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
var current_slow_target = null
var max_targets: int = 1
var tower_id: String = "Turt Turt Turt Sahur"  # display name, changes with upgrades

func _ready():
	super._ready()
	cost = 1500
	anim_sprite.animation_looped.connect(_on_animation_looped)
	anim_sprite.stop()
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _set_animation_sheet(texture: Texture2D) -> void:
	var was_playing: bool = anim_sprite.is_playing()
	anim_sprite.sprite_frames = _build_sprite_frames(texture)
	anim_sprite.animation = TOWER_ANIMATION_NAME
	anim_sprite.frame = 0
	anim_sprite.scale = UPGRADED_SPRITE_SCALE
	if was_playing:
		anim_sprite.play()
	else:
		anim_sprite.stop()

func _build_sprite_frames(texture: Texture2D) -> SpriteFrames:
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	if not sprite_frames.has_animation(TOWER_ANIMATION_NAME):
		sprite_frames.add_animation(TOWER_ANIMATION_NAME)

	sprite_frames.set_animation_loop(TOWER_ANIMATION_NAME, true)
	sprite_frames.set_animation_speed(TOWER_ANIMATION_NAME, TOWER_ANIMATION_SPEED)

	var source_image: Image = texture.get_image()
	var sheet_width: float = float(texture.get_width())
	var sheet_height: float = float(texture.get_height())
	for row in range(TOWER_FRAME_ROWS):
		for column in range(TOWER_FRAME_COLUMNS):
			var source_x: int = int(round(column * sheet_width / TOWER_FRAME_COLUMNS))
			var source_next_x: int = int(round((column + 1) * sheet_width / TOWER_FRAME_COLUMNS))
			var source_y: int = int(round(row * sheet_height / TOWER_FRAME_ROWS))
			var source_next_y: int = int(round((row + 1) * sheet_height / TOWER_FRAME_ROWS))
			var source_frame_width: int = source_next_x - source_x
			var source_frame_height: int = source_next_y - source_y
			var source_frame: Image = source_image.get_region(
				Rect2i(
					source_x,
					source_y,
					source_frame_width,
					source_frame_height
				)
			)
			var used_rect: Rect2i = source_frame.get_used_rect()
			var frame_image: Image = Image.create_empty(TOWER_FRAME_WIDTH, TOWER_FRAME_HEIGHT, false, source_image.get_format())
			frame_image.fill(Color.TRANSPARENT)
			if used_rect.size.x > 0 and used_rect.size.y > 0:
				frame_image.blit_rect(
					source_frame,
					used_rect,
					Vector2i(
						(TOWER_FRAME_WIDTH - used_rect.size.x) / 2,
						TOWER_FRAME_HEIGHT - used_rect.size.y
					)
				)
			sprite_frames.add_frame(TOWER_ANIMATION_NAME, ImageTexture.create_from_image(frame_image))
	return sprite_frames

func get_multiple_targets() -> Array:
	var bodies = detection_area.get_overlapping_bodies()
	var targets = []
	for body in bodies:
		if body.is_in_group("zombies") and body.get("is_stealth") != true:
			targets.append(body)
		if targets.size() >= max_targets:
			break
	return targets

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		if is_placed and starter and starter.playing and not anim_sprite.is_playing():
			anim_sprite.play()

func _on_body_exited(body):
	if body == current_slow_target:
		clear_slow_effect(body)
		current_slow_target = null
	if get_multiple_targets().is_empty():
		anim_sprite.stop()

func _process(_delta):
	if is_placed and starter and starter.playing:
		if not get_multiple_targets().is_empty():
			if not anim_sprite.is_playing():
				anim_sprite.play()
		else:
			anim_sprite.stop()

func _on_animation_looped():
	if not starter or not starter.playing or not is_placed:
		return
	var targets = get_multiple_targets()
	if targets.is_empty():
		anim_sprite.stop()
		return
	for target in targets:
		_apply_hit(target)

#func _apply_hit(target):
	#if not is_instance_valid(target):
		#return
	#if target.has_method("take_damage"):
		#target.take_damage(attack_damage)
	#if max_targets == 1:
		#if current_slow_target and current_slow_target != target and is_instance_valid(current_slow_target):
			#clear_slow_effect(current_slow_target)
		#current_slow_target = target
		#if "speed_modifier" in target:
			#target.speed_modifier = slow_factor
	#else:
		#if "speed_modifier" in target:
			#target.speed_modifier = slow_factor

func _apply_hit(target):
	if not is_instance_valid(target):
		return
		
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
		
	if target.get("is_boss") == true:
		return

	if max_targets == 1:
		if current_slow_target and current_slow_target != target and is_instance_valid(current_slow_target):
			clear_slow_effect(current_slow_target)
		current_slow_target = target
		if "speed_modifier" in target:
			target.speed_modifier = slow_factor
	else:
		if "speed_modifier" in target:
			target.speed_modifier = slow_factor

func clear_slow_effect(target):
	if is_instance_valid(target) and "speed_modifier" in target:
		target.speed_modifier = 1.0

func _input(event):
	if not is_placed:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var space = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = mouse_pos
		query.collide_with_bodies = true
		var results = space.intersect_point(query)
		for result in results:
			if result["collider"] == self:
				Signal_Bus.tower_selected.emit(self)
				break

var tower_name = "Turt Turt Turt Sahur"  # fixed ID, used for UpgradeManager lookup
var upgrades = {
	"left": {
		"name": "Tung",
		"tiers": [
			{"label": "Tung", "cost": 0},
			{"label": "Tung^2", "cost": 0},
			{"label": "Tung^3", "cost": 0}
		]
	},
	"right": {
		"name": "Larp",
		"tiers": [
			{"label": "Larp", "cost": 0},
			{"label": "Larp^2", "cost": 0},
			{"label": "Larp^3", "cost": 0}
		]
	}
}
var left_level = 0
var right_level = 0
var chosen_branch = ""

func purchase_upgrade(branch: String):
	if chosen_branch != "" and chosen_branch != branch:
		return
	var ucost = 0
	if branch == "left":
		ucost = upgrades["left"]["tiers"][left_level]["cost"]
	elif branch == "right":
		ucost = upgrades["right"]["tiers"][right_level]["cost"]
	if branch == "left" and left_level == 2 and not UpgradeManager.can_purchase_tier3_left(tower_name):
		return
	if branch == "right" and right_level == 2 and not UpgradeManager.can_purchase_tier3_right(tower_name):
		return
	var currency_manager = get_node("/root/Game/UI/HUD/CurrencyManager")
	if currency_manager.shellings < ucost:
		return
	currency_manager.spend_shellings(ucost)
	if chosen_branch == "":
		chosen_branch = branch
	if branch == "left":
		apply_left_upgrade()
		left_level += 1
		if left_level >= 3:
			UpgradeManager.register_tier3_left(tower_name)
	elif branch == "right":
		apply_right_upgrade()
		right_level += 1
		if right_level >= 3:
			UpgradeManager.register_tier3_right(tower_name)
	refresh_range_indicator()

func apply_left_upgrade():
	match left_level:
		0:
			fire_rate *= .5
			tower_id = "Tung Turt Turt Sahur"
		1:
			detection_area.scale *= 1.5
			tower_id = "Tung Tung Turt Sahur"
		2:
			fire_rate *= .5
			tower_id = "Tung Tung Tung Sahur"
			_set_animation_sheet(TUNG_FRAMES_TEXTURE)

func apply_right_upgrade():
	match right_level:
		0:
			slow_factor *= .5
			tower_id = "Larp Turt Turt Sahur"
		1:
			max_targets = 3
			tower_id = "Larp Larp Turt Sahur"
		2:
			max_targets = 6
			tower_id = "Larp Larp Larp Sahur"
			_set_animation_sheet(LARP_FRAMES_TEXTURE)

func sell() -> void:
	if left_level >= 3:
		UpgradeManager.unregister_tier3_left(tower_name)
	if right_level >= 3:
		UpgradeManager.unregister_tier3_right(tower_name)
	super.sell()
