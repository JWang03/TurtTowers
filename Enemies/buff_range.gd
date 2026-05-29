extends Area2D

@export var speed_boost_factor: float = 1.5
@export var buff_duration: float = 5.0

func _ready():
	# Connect the Area2D signals to detect when a zombie enters/leaves
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Self-destruct timer so the track doesn't stay cluttered forever
	var lifetime_timer = get_tree().create_timer(buff_duration)
	lifetime_timer.timeout.connect(queue_free)

func _on_body_entered(body: Node2D):
	# Check if the body entering the puddle is another zombie/enemy
	if body.is_in_group("zombies") and body != self:
		# Multiply their current speed modifier
		body.speed_modifier *= speed_boost_factor

func _on_body_exited(body: Node2D):
	if body.is_in_group("zombies") and body != self:
		# Revert their speed back to normal when they leave the puddle
		body.speed_modifier /= speed_boost_factor
