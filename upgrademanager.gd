extends Node

var tier3_left_owners: Dictionary = {}   # tower_name -> count
var tier3_right_owners: Dictionary = {}

func can_purchase_tier3_left(tower_name: String) -> bool:
	return tier3_left_owners.get(tower_name, 0) == 0

func can_purchase_tier3_right(tower_name: String) -> bool:
	return tier3_right_owners.get(tower_name, 0) == 0

func register_tier3_left(tower_name: String):
	tier3_left_owners[tower_name] = tier3_left_owners.get(tower_name, 0) + 1

func register_tier3_right(tower_name: String):
	tier3_right_owners[tower_name] = tier3_right_owners.get(tower_name, 0) + 1

func unregister_tier3_left(tower_name: String):
	tier3_left_owners[tower_name] = max(0, tier3_left_owners.get(tower_name, 0) - 1)

func unregister_tier3_right(tower_name: String):
	tier3_right_owners[tower_name] = max(0, tier3_right_owners.get(tower_name, 0) - 1)

func clear_all() -> void:
	tier3_left_owners.clear()
	tier3_right_owners.clear()
