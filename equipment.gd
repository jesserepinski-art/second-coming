class_name Equipment extends Resource

enum Slot { WEAPON, ARMOR, TRINKET }

@export var name: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: AtlasTexture = null
@export var slot: Slot = Slot.WEAPON
@export var value: int = 0


@export var attack_bonus: int = 0
@export var magic_attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var hp_max_bonus: int = 0
@export var mp_max_bonus: int = 0
@export var speed_bonus: int = 0
@export var accuracy_bonus: int = 0
@export var evasion_bonus: int = 0
@export var crit_chance_bonus: int = 0


@export var attack_data: AttackData = null
@export var granted_spell: Item = null


@export var status_resistances: Dictionary = {}  
