extends Area2D

@export var speed: float = 1000.0
@export var damage: int = 5
var damage_multiplier: float = 1.0

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		if body.has_method("take_damage"):
			body.take_damage(damage * damage_multiplier)
		BulletPool.return_bullet(self)
		
func _ready():
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func activate(pos: Vector2, rot: float):
	global_position = pos
	global_rotation = rot
	show()
	process_mode = Node.PROCESS_MODE_INHERIT

func _process(delta):
	position += transform.x * speed * delta

func _on_screen_exited():
	BulletPool.return_bullet(self)
