extends Area2D

@export var speed: float = 500.0
@export var damage: int = 1

func _ready():
	# Connect the signal so the bullet knows when it hits something
	body_entered.connect(_on_body_entered)

func _process(delta):
	# Move to the right every frame
	position.x += speed * delta

func _on_body_entered(body):
	# Check if what we hit is actually a zombie
	if body.is_in_group("zombies"):
		# Check if the zombie has a 'take_damage' function before calling it
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		# Destroy the bullet on impact
		queue_free()

# This is a 'VisibilityNotifier' trick or a simple distance check
# To keep the game fast, delete bullets that fly off the screen
func _on_screen_exited():
	queue_free()
