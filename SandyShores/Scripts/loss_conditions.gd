extends Node

var lives = 100

@onready var label = $"../Lives/LivesLabel"

func update_label():
	label.text = str(lives)
func _ready():
	update_label()

func add_lives(amount: int):
	lives += amount
	update_label()

func spend_lives(amount: int):
	lives -= amount
	var run_stats := get_node_or_null("/root/RunStats")
	if run_stats:
		run_stats.record_lives_lost(amount)
	update_label()


func is_alive(lives):
	if lives<=0:
		return false
	else:
		return true
		
