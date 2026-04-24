extends Panel

var tower = null

@onready var label = $TowerName
@onready var top_btn = $TopButton
@onready var bot_btn = $BottomButton

func _ready():
	visible = false
	top_btn.pressed.connect(_on_top_pressed)
	bot_btn.pressed.connect(_on_bot_pressed)

func show_for(t):
	tower = t
	visible = true
	refresh()

func refresh():
	label.text = "Soldier"  # we can make this dynamic later
	
	top_btn.text = get_upgrade_label(0)
	bot_btn.text = get_upgrade_label(1)
	
	top_btn.disabled = tower.upgrade_branch == 1 or tower.upgrade_tier >= 3
	bot_btn.disabled = tower.upgrade_branch == 0 or tower.upgrade_tier >= 3
	
	top_btn.modulate = Color(0.4, 0.4, 0.4) if top_btn.disabled else Color.WHITE
	bot_btn.modulate = Color(0.4, 0.4, 0.4) if bot_btn.disabled else Color.WHITE

func get_upgrade_label(branch: int) -> String:
	if tower.upgrade_tier >= 3 and tower.upgrade_branch == branch:
		return "MAXED"
	if tower.upgrade_branch != -1 and tower.upgrade_branch != branch:
		return "LOCKED"
	var tier = tower.upgrade_tier
	return tower.UPGRADES[branch][tier]["label"]

func _on_top_pressed():
	tower.apply_upgrade(0)
	refresh()

func _on_bot_pressed():
	tower.apply_upgrade(1)
	refresh()
