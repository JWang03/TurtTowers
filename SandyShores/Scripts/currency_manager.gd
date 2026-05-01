extends Node

var shellings: int = 10000

@onready var label = $"../Money/ShellingsLabel"

func update_label():
	label.text = str(shellings)
func _ready():
	update_label()

func add_shellings(amount: int):
	shellings += amount
	update_label()

func spend_shellings(amount: int):
	shellings -= amount
	update_label()
