class_name SlotMenu extends Menu

func _ready() -> void:
	super()
	hide()

func refresh(actor: BattleActor) -> void:
	var b := get_buttons()
	b[0].text = "Weapon: " + (actor.equipped_weapon.display_name if actor.equipped_weapon else "None")
	b[1].text = "Armor: " + (actor.equipped_armor.display_name if actor.equipped_armor else "None")
	b[2].text = "Trinket: " + (actor.equipped_trinket.display_name if actor.equipped_trinket else "None")
