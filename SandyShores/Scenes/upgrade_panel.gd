extends Control

var current_tower = null

func _ready():
	visible = false
	Signal_Bus.tower_selected.connect(_on_tower_selected)
	Signal_Bus.tower_deselected.connect(_on_tower_deselected)

func _on_tower_selected(tower):
	current_tower = tower
	populate(tower)
	visible = true

func _on_tower_deselected():
	current_tower = null
	visible = false

func populate(tower):
	$TowerName.text = tower.tower_name
	$HBoxContainer/LeftButtons/LeftPathLabel.text = tower.upgrades["left"]["name"]
	$HBoxContainer/RightButtons/RightPathLabel.text = tower.upgrades["right"]["name"]
	
	var left_tiers = tower.upgrades["left"]["tiers"]
	var right_tiers = tower.upgrades["right"]["tiers"]
	
	var left_locked = tower.chosen_branch == "right"
	var right_locked = tower.chosen_branch == "left"
	
	for i in range(3):
		var btn = $HBoxContainer/LeftButtons.get_child(i + 1)
		if left_locked:
			btn.text = "Locked"
			btn.disabled = true
		elif i < tower.left_level:
			btn.text = "Purchased"
			btn.disabled = true
		elif i == tower.left_level:
			btn.text = left_tiers[i]["label"] + " ($" + str(left_tiers[i]["cost"]) + ")"
			btn.disabled = false
		else:
			btn.text = left_tiers[i]["label"]
			btn.disabled = true
	
	for i in range(3):
		var btn = $HBoxContainer/RightButtons.get_child(i + 1)
		if right_locked:
			btn.text = "Locked"
			btn.disabled = true
		elif i < tower.right_level:
			btn.text = "Purchased"
			btn.disabled = true
		elif i == tower.right_level:
			btn.text = right_tiers[i]["label"] + " ($" + str(right_tiers[i]["cost"]) + ")"
			btn.disabled = false
		else:
			btn.text = right_tiers[i]["label"]
			btn.disabled = true

func _on_left_upgrade_pressed():
	print("current_tower: ", current_tower)
	if current_tower:
		current_tower.purchase_upgrade("left")
		populate(current_tower)

func _on_right_upgrade_pressed():
	if current_tower:
		current_tower.purchase_upgrade("right")
		populate(current_tower)

func _on_sell_pressed():
	if current_tower:
		current_tower.queue_free()
		current_tower = null
		visible = false
