extends Node

@onready var play_button = get_node("/root/Game/UI/Start_Pause/PlayButton")
@export var enemy_scene: PackedScene
@export var enemy_path: Path2D
var spawnrate = 50
var count = 1
func spawn_enemy(scene: PackedScene):
	if enemy_scene == null or enemy_path == null:
		return

	var follow = PathFollow2D.new()
	follow.loop = false
	enemy_path.add_child(follow)

	var enemy = enemy_scene.instantiate()
	follow.add_child(enemy)

	follow.progress = 0.0
	
	
func _ready():
	pass
func _process(delta: float) -> void:
	if play_button.playing == true:
		if count % spawnrate == 0:
			spawn_enemy()
		count+=1
