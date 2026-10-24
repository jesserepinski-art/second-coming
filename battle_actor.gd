class_name BattleActor extends Resource
signal statuses_changed
signal hp_changed(hp: int, hp_max: int, amount_change: int)
enum StatType { HP, MP, ATTACK, MAGIC_ATTACK, DEFENSE, SPEED, CRIT_CHANCE }
@export_multiline var attack_quotes: Array[String] = []

@export var battle_observations: Array[String] = []

@export_multiline var hurt_quotes: Array[String] = []

@export_multiline var death_quotes: Array[String] = []

@export_multiline var idle_quotes: Array[String] = []
@export var hurt_sound: AudioStream
@export var death_sound: AudioStream
@export var talk_sound: AudioStream
@export var sprite: Texture2D = null
@export var battle_sprite_frames: SpriteFrames = null
@export var idle_detail_animations: Array[String] = []
@export var portrait: Texture2D = null
@export_multiline var description: String = ""
@export var attack_sprite: Texture2D = null
@export var name: String = ""
@export var overworld_sprite_frames: SpriteFrames = null

@export var custom_battle_rig: PackedScene = null  
@export var hp_max: int = 1
@export var mp_max: int = 0
@export var attack: int = 2
@export var magic_attack: int = 2
@export var defense: int = 1
@export var speed: int = 10
@export_range(0, 100)
var accuracy: int = 100
@export var ability_points: int = 0
@export var points_per_level: int = 3
@export_range(0, 100)
var evasion: int = 0
@export_range(0, 100)
var crit_chance: int = 5

@export var crit_multiplier: float = 1.5
@export var items: Array[Item] = []
@export var attacks: Array[AttackData] = []
@export var spells: Array[Item] = []
@export var gold: int = 1
@export var spell_cast_animation: StringName = &"cast_spell"
@export var statuses: Array[StatusEffect] = []
@export var level: int = 1
@export var xp_to_next: int = 10
@export var xp: int = 1
@export var xp_reward: int = 10
@export var gold_reward: int = 5
var queued_action: EventQueue.Actions = -1
var queued_target: BattleActor = null
var queued_payload: Resource = null
@export var hp: int = hp_max
@export var mp: int = mp_max
var inventory: Inventory = null
var _last_battle_observation := -1

func init() -> void:
	hp = hp_max
	mp = mp_max

	if items:
		inventory = Inventory.new()
	for item: Item in items:
		inventory.add_item(item)
@export var equipped_weapon: Equipment = null
@export var equipped_armor: Equipment = null
@export var equipped_trinket: Equipment = null

func equip(item: Equipment) -> Equipment:
	print("Equipping: ", item.display_name, " to slot: ", item.slot)
	var previous: Equipment = null
	match item.slot:
		Equipment.Slot.WEAPON:
			previous = equipped_weapon
			equipped_weapon = item
			print("equipped_weapon is now: ", equipped_weapon)
		Equipment.Slot.ARMOR:
			previous = equipped_armor
			equipped_armor = item
		Equipment.Slot.TRINKET:
			previous = equipped_trinket
			equipped_trinket = item

	_apply_equipment_delta(previous, item)
	return previous

func unequip(slot: Equipment.Slot) -> Equipment:
	var previous: Equipment = null
	match slot:
		Equipment.Slot.WEAPON:
			previous = equipped_weapon
			equipped_weapon = null
		Equipment.Slot.ARMOR:
			previous = equipped_armor
			equipped_armor = null
		Equipment.Slot.TRINKET:
			previous = equipped_trinket
			equipped_trinket = null

	_apply_equipment_delta(previous, null)
	return previous

func _apply_equipment_delta(old_item: Equipment, new_item: Equipment) -> void:
	
	if old_item:
		attack -= old_item.attack_bonus
		magic_attack -= old_item.magic_attack_bonus
		defense -= old_item.defense_bonus
		hp_max -= old_item.hp_max_bonus
		mp_max -= old_item.mp_max_bonus
		speed -= old_item.speed_bonus
		accuracy -= old_item.accuracy_bonus
		evasion -= old_item.evasion_bonus
		crit_chance -= old_item.crit_chance_bonus

	
	if new_item:
		attack += new_item.attack_bonus
		magic_attack += new_item.magic_attack_bonus
		defense += new_item.defense_bonus
		hp_max += new_item.hp_max_bonus
		mp_max += new_item.mp_max_bonus
		speed += new_item.speed_bonus
		accuracy += new_item.accuracy_bonus
		evasion += new_item.evasion_bonus
		crit_chance += new_item.crit_chance_bonus

	hp = min(hp, hp_max)
	mp = min(mp, mp_max)

func get_equipment_list() -> Array[Equipment]:
	var list: Array[Equipment] = []
	if equipped_weapon: list.append(equipped_weapon)
	if equipped_armor: list.append(equipped_armor)
	if equipped_trinket: list.append(equipped_trinket)
	return list

func copy() -> BattleActor:
	var dup: BattleActor = duplicate()
	dup.init()
	return dup

func is_defeated() -> bool:
	return hp <= 0

func can_act() -> bool:
	return not is_defeated()
	




func get_battle_observation() -> String:

	if battle_observations.is_empty():
		return ""

	if battle_observations.size() == 1:
		return battle_observations[0]

	var i := randi_range(0, battle_observations.size() - 1)

	while i == _last_battle_observation:
		i = randi_range(0, battle_observations.size() - 1)

	_last_battle_observation = i

	return battle_observations[i]

func damage_roll(target: BattleActor) -> int:
	var damage: int = maxi(1, get_attack() - target.get_defense())
	return -damage
func get_speed() -> int:
	var value: int = speed

	for status: StatusEffect in statuses:
		match status.type:
			StatusEffect.StatusType.SLOW:
				value -= int(status.potency)

			StatusEffect.StatusType.HASTE:
				value += int(status.potency)

	return max(1, value)
func get_attack() -> int:
	var value: int = attack
	if equipped_weapon:
		value += equipped_weapon.attack_bonus
	if equipped_armor:
		value += equipped_armor.attack_bonus
	if equipped_trinket:
		value += equipped_trinket.attack_bonus

	for status: StatusEffect in statuses:
		match status.type:
			StatusEffect.StatusType.ATTACK_UP:
				value += int(status.potency)
			StatusEffect.StatusType.ATTACK_DOWN:
				value -= int(status.potency)

	return maxi(1, value)
func get_magic_attack() -> int:
	var value: int = magic_attack
	if equipped_weapon:
		value += equipped_weapon.magic_attack_bonus
	if equipped_armor:
		value += equipped_armor.magic_attack_bonus
	if equipped_trinket:
		value += equipped_trinket.magic_attack_bonus

	for status: StatusEffect in statuses:
		match status.type:
			StatusEffect.StatusType.ATTACK_UP:
				value += int(status.potency)
			StatusEffect.StatusType.ATTACK_DOWN:
				value -= int(status.potency)

	return maxi(1, value)
func get_hp_max() -> int:
	var value := hp_max
	for e in get_equipment_list():
		value += e.hp_max_bonus
	return value
func get_defense() -> int:
	var value: int = defense

	for status: StatusEffect in statuses:
		match status.type:
			StatusEffect.StatusType.DEFENSE_UP:
				value += int(status.potency)

			StatusEffect.StatusType.DEFENSE_DOWN:
				value -= int(status.potency)

	return maxi(0, value)
func get_accuracy() -> int:
	var value: int = accuracy

	for status: StatusEffect in statuses:
		match status.type:
			StatusEffect.StatusType.BLIND:
				value -= int(status.potency)

	return clampi(value, 0, 100)
func get_evasion() -> int:
	var value: int = evasion

	for status: StatusEffect in statuses:
		match status.type:
			StatusEffect.StatusType.EVASION_UP:
				value += int(status.potency)

	return clampi(value, 0, 100)
func can_hit(target: BattleActor) -> bool:
	var chance := clampi(
		get_accuracy() - target.get_evasion(),
		0,
		100
	)

	return randi_range(1, 100) <= chance
func is_critical(bonus: int = 0) -> bool:
	var chance := clampi(crit_chance + bonus, 0, 100)
	return randi_range(1, 100) <= chance
func healhurt(value: int) -> int:
	var previous_hp: int = hp
	
	
	hp = clampi(hp + value, 0, hp_max)
	
	var value_change: int = hp - previous_hp
	hp_changed.emit(hp, hp_max, value_change)
	return value_change

func add_status(status: StatusEffect) -> void:

	
	for existing: StatusEffect in statuses:
		if existing.type == status.type:
			existing.turns = status.turns
			statuses_changed.emit()
			return

	
	statuses.append(status.duplicate(true))
	statuses_changed.emit()
	

func has_status(type: StatusEffect.StatusType) -> bool:
	for status in statuses:
		if status.type == type:
			return true
	return false


func remove_status(type: StatusEffect.StatusType) -> void:
	for status in statuses:
		if status.type == type:
			statuses.erase(status)
			statuses_changed.emit()
			return
func process_start_of_turn() -> bool:
	if has_status(StatusEffect.StatusType.STUN):
		return false
	if has_status(StatusEffect.StatusType.SLEEP):
		var roll := randi_range(1, 100)
		if roll <= 70:  
			return false
		else:
			remove_status(StatusEffect.StatusType.SLEEP)
	return true

func process_end_of_turn() -> void:
	pass
func gain_xp(amount: int) -> bool:
	xp += amount

	var leveled := false

	while xp >= xp_to_next:
		xp -= xp_to_next
		level_up()
		leveled = true

	return leveled
func level_up():
	level += 1

	hp_max += 5
	mp_max += 2
	attack += 1
	magic_attack += 1
	defense += 1
	speed += 1
	ability_points += points_per_level

	hp = hp_max
	mp = mp_max

	xp_to_next = int(round(xp_to_next * 1.3))
func get_status_resistance(type: StatusEffect.StatusType) -> float:
	if equipped_armor and equipped_armor.status_resistances.has(type):
		return equipped_armor.status_resistances[type]
	return 0.0
func scale_to_level(target_level: int) -> void:
	level = target_level
	var t := clampf(float(target_level - 1) / 99.0, 0.0, 1.0)
	var curved_t := pow(t, 1.6)

	hp_max = int(round(lerp(15.0, 3000.0, curved_t)))
	mp_max = int(round(lerp(5.0, 200.0, curved_t)))
	attack = int(round(lerp(3.0, 250.0, curved_t)))
	magic_attack = int(round(lerp(3.0, 250.0, curved_t)))
	defense = int(round(lerp(2.0, 150.0, curved_t)))
	speed = int(round(lerp(8.0, 60.0, curved_t)))

	xp_reward = int(round(lerp(5.0, 800.0, curved_t)))
	gold_reward = int(round(lerp(2.0, 400.0, curved_t)))

	hp = hp_max
	mp = mp_max
	xp_to_next = int(round(10.0 * pow(1.045, target_level)))
func spend_point(stat: StatType) -> bool:
	if ability_points <= 0:
		return false

	ability_points -= 1

	match stat:
		StatType.HP:
			hp_max += 5
			hp += 5
		StatType.MP:
			mp_max += 2
			mp += 2
		StatType.ATTACK:
			attack += 1
		StatType.MAGIC_ATTACK:
			magic_attack += 1
		StatType.DEFENSE:
			defense += 1
		StatType.SPEED:
			speed += 1
		StatType.CRIT_CHANCE:
			crit_chance += 1

	return true
