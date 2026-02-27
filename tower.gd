extends StaticBody2D

## Drag and drop your Bullet.tscn here in the Inspector
@export var bullet_scene: PackedScene 
@export var fire_rate: float = 1.5

@onready var muzzle = $Muzzle
@onready var timer = $Timer
@onready var detection_area = $Area2D # Make sure your Area2D is named this or update here

var targets_in_range: Array = []

func _ready():
	# Configure Timer via code so you don't have to do it in the UI
	timer.wait_time = fire_rate
	timer.one_shot = false
	
	# Connect signals via code for a "one-script" setup
	detection_area.body_entered.connect(_on_zombie_entered)
	detection_area.body_exited.connect(_on_zombie_exited)
	timer.timeout.connect(_on_timer_timeout)

func _on_zombie_entered(body):
	# Assuming your zombies are in a group called "zombies"
	if body.is_in_group("zombies"):
		targets_in_range.append(body)
		# Start shooting immediately if the timer isn't already running
		if timer.is_stopped():
			shoot()
			timer.start()

func _on_zombie_exited(body):
	if body in targets_in_range:
		targets_in_range.erase(body)
		
	# Stop shooting if the lane is empty
	if targets_in_range.is_empty():
		timer.stop()

func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		# Add bullet to the root scene so it moves independently of the tower
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = muzzle.global_position
	else:
		print("Warning: No bullet_scene assigned to the Tower!")

func _on_timer_timeout():
	# Double check we still have targets before firing
	if not targets_in_range.is_empty():
		shoot()
	else:
		timer.stop()
