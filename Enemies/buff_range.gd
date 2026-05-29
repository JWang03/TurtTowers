extends Area2D

@export var speed_boost_factor: float = 4.0
@export var buff_duration: float = 5.0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	var lifetime_timer = get_tree().create_timer(buff_duration)
	lifetime_timer.timeout.connect(queue_free)

func _on_body_entered(body: Node2D):
	if body.is_in_group("zombies") and body != self:
		body.speed_modifier *= speed_boost_factor

func _on_body_exited(body: Node2D):
	if body.is_in_group("zombies") and body != self:
		body.speed_modifier /= speed_boost_factor
