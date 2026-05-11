extends Area2D

@export var move_speed: float = 240.0
@export var damage: float = 15.0

@onready var starter = get_node_or_null("/root/Game/UI/Buttons/PlayButton")
var my_follower: PathFollow2D = null

func _ready():
	body_entered.connect(_on_body_entered)

func set_follower(f: PathFollow2D):
	my_follower = f
	if has_node("Sprite2D"):
		$Sprite2D.flip_h = true 

func _process(delta):
	if not starter or not starter.playing:
		return
		
	if my_follower:
		my_follower.progress -= move_speed * delta
		
		if my_follower.progress <= 0:
			cleanup()

func _on_body_entered(body):
	if body.is_in_group("zombies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		cleanup()

func cleanup():
	if my_follower:
		my_follower.queue_free()
	else:
		queue_free()
