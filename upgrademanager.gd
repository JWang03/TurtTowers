extends Node

var tier3_left_count: int = 0
var tier3_right_count: int = 0

func can_purchase_tier3_left() -> bool:
	return tier3_left_count == 0

func can_purchase_tier3_right() -> bool:
	return tier3_right_count == 0

func register_tier3_left():
	tier3_left_count += 1

func register_tier3_right():
	tier3_right_count += 1

func unregister_tier3_left():
	tier3_left_count = max(0, tier3_left_count - 1)

func unregister_tier3_right():
	tier3_right_count = max(0, tier3_right_count - 1)
