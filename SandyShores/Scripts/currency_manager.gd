extends Node

var shellings: int = 10550

@onready var label = $"../Money/ShellingsLabel"

func update_label():
	label.text = str(shellings)
func _ready():
	update_label()

func add_shellings(amount: int, counts_as_generated: bool = true):
	shellings += amount
	var run_stats := get_node_or_null("/root/RunStats")
	if counts_as_generated and run_stats:
		run_stats.record_cash_generated(amount)
	update_label()

func spend_shellings(amount: float):
	shellings -= amount
	update_label()
