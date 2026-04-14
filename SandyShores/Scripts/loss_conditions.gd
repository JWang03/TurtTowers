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
	update_label()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		add_lives(10)
func is_alive(lives):
	if lives<=0:
		return false
	else:
		return true
		
