extends "res://enemies/zombie.gd"

@export var shield_health: float = 50
@export var shield_radius: float = 60.0

@onready var shield_node = $ShieldArea
@onready var shield_sprite = $ShieldArea/Sprite2D

var is_shield_active: bool = false

func _ready():
	super._ready()
	add_to_group("shield_mobs")
	
	health = 20
	speed = 5
	shield_node.monitoring = false
	shield_node.visible = false
	
	start_shield_timer()

func start_shield_timer():
	await get_tree().create_timer(randf_range(0.5,8.0)).timeout
	deploy_shield()

func deploy_shield():
	if health <= 0: return
	
	is_shield_active = true
	shield_node.monitoring = true
	shield_node.visible = true
	
	var tween = create_tween()
	shield_node.scale = Vector2.ZERO
	tween.tween_property(shield_node, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK)

func take_shield_damage(amount):
	shield_health -= amount
	# Feedback effect
	shield_sprite.modulate = Color(2, 2, 2, 1) 
	await get_tree().create_timer(0.05).timeout
	if is_instance_valid(shield_sprite):
		shield_sprite.modulate = Color(1, 1, 1, 0.6)
	
	if shield_health <= 0:
		break_shield()

func break_shield():
	is_shield_active = false
	shield_node.monitoring = false
	shield_node.visible = false
	shield_health = 50 
	start_shield_timer()

func take_damage(amount):
	if is_shield_active:
		take_shield_damage(amount)
	else:
		super.take_damage(amount)
