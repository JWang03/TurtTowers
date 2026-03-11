extends Node

var shellings: int = 100

@onready var label = $"../ShellingsLabel"

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


	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		add_shellings(10)
