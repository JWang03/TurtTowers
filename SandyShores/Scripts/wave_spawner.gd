extends Node

@export var enemy_scene: PackedScene
@export var enemy_path: Path2D
var spawnrate = 50
var count
func spawn_enemy():
	if enemy_scene == null or enemy_path == null:
		return

	var follow = PathFollow2D.new()
	follow.loop = false
	enemy_path.add_child(follow)

	var enemy = enemy_scene.instantiate()
	follow.add_child(enemy)

	follow.progress = 0.0
	
	
func _ready():
	spawn_enemy()
	count = 1
func _process(delta: float) -> void:
	if count % spawnrate == 0:
		spawn_enemy()
	count+=1
