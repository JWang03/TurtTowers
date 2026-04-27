extends Node

const BULLET_SCENE = preload("res://Towers/bullet.tscn")  # adjust path
const POOL_SIZE = 200  # tune this to how many bullets you realistically need

var _pool: Array = []

func _ready():
	# Pre-spawn all bullets at startup
	for i in POOL_SIZE:
		var bullet = BULLET_SCENE.instantiate()
		bullet.hide()
		bullet.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(bullet)
		_pool.append(bullet)

func get_bullet() -> Node:
	for bullet in _pool:
		if not bullet.visible:
			return bullet
	return null  # pool exhausted, return null and handle gracefully

func return_bullet(bullet: Node):
	bullet.hide()
	bullet.process_mode = Node.PROCESS_MODE_DISABLED
	bullet.set_physics_process(false)
