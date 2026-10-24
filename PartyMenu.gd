class_name PartyMenu extends Menu
@onready var inventory_menu: InventoryScreen = $InventoryScreen
var party: Array[BattleActor] = []:
	set(value):
		party = value
		for button: PartyButton in get_buttons():
			button.actor = party[button.get_index()] if button.get_index() < party.size() else null

func _ready() -> void:
	super()
	hide()
	party = Data.party
