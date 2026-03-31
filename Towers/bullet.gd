extends Area2D

@export var speed: float = 1000
@export var damage: int = 2

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		queue_free()

func _on_screen_exited():
	queue_free()
