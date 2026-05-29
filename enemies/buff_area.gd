extends Area2D

@export var speed_boost_factor: float = 5.0
@export var duration: float = 10.0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	start_lifetime_timer()

func start_lifetime_timer():
	await get_tree().create_timer(duration).timeout
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	expire_buff()

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		body.speed_modifier = speed_boost_factor
		print("Zombie buffed: ", body.name)

func _on_body_exited(body):
	if body.is_in_group("zombies"):
		body.speed_modifier = 1.0
		print("Zombie left buff range: ", body.name)

func expire_buff():
	for body in get_overlapping_bodies():
		if body.is_in_group("zombies"):
			body.speed_modifier = 1.0
	
	queue_free()
