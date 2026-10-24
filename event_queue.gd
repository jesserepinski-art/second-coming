class_name EventQueue
extends Node

enum Actions {
	FIGHT,
	MAGIC,
	ITEM,
	RUN,
}

const SHORT: float = 0.75
const LONG: float = 1.25

var events: Array[Dictionary] = []

@onready var main_attack: VideoStreamPlayer = $"../MainAttack"
@onready var textbox: Textbox = Globals.textbox


func add(action: Actions, actor: BattleActor, target: BattleActor, action_payload: Resource) -> void:
	print(
		"QUEUE:",
		actor.name,
		" action=",
		action,
		" payload=",
		action_payload
	)

	events.append({
		"action": action,
		"actor": actor,
		"target": target,
		"payload": action_payload
	})

func pop_back() -> void:
	events.pop_back()



func shuffle() -> void:
	events.shuffle()


func wait(duration: float) -> void:
	await get_tree().create_timer(duration).timeout


func run() -> void:
	if events.is_empty():
		textbox.stop()
		return

	var event: Dictionary = events.pop_front()

	var action: Actions = event.action
	var actor: BattleActor = event.actor
	var target: BattleActor = event.target
	print("Running event for actor: ", actor.name, " action: ", action)
	var payload: Resource = event.payload
	if target == null:
		await run()
		return
	var target_is_friendly: bool = Data.party.has(target)

	var text := actor.name
	var can_act := actor.process_start_of_turn()
	print(actor.name, actor.hp, actor.get_instance_id())
	if actor.is_defeated():
		await run()
		return

	if !can_act:
		textbox.start("", ["%s can't move!" % actor.name])
		await textbox.finished
		await run()
		return

	if !actor.can_act():
		await run()
		return


	if target.is_defeated():
		var targets: Array = []

		if target_is_friendly:
			targets = Data.party.duplicate()
		else:
			for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
				if enemy.data and !enemy.data.is_defeated():
					targets.append(enemy.data)

		targets.shuffle()

		target = null
		for candidate: BattleActor in targets:
			if !candidate.is_defeated():
				target = candidate
				break

		if target == null:
			print("SILENT SKIP: ", actor.name, " had a null target for action ", action, " payload ", payload)
			await run()
			return

	match action:

		Actions.FIGHT:

			var hit := actor.can_hit(target)
			
			var critical := false
			var damage := 0
			var timing_multiplier := 1.5


			if hit:
				if payload is AttackData:
					var attack := payload as AttackData
					if attack.can_crit:
						critical = actor.is_critical(attack.crit_bonus)

			
			damage = actor.damage_roll(target)
			damage = int(round(damage * timing_multiplier))

			var attack_text := ""

			if actor.attack_quotes.size() > 0:
				attack_text = actor.attack_quotes.pick_random()
			else:
				attack_text = "%s attacks!" % actor.name

			textbox.start("", [attack_text])
			await wait(SHORT)


			
			if target_is_friendly == false and Data.party.has(actor):
				if payload is AttackData:
					Globals.battle_effects.play_player_attack(payload)
					Globals.timing_ring.start()
					var tier: String = await Globals.timing_ring.completed
					timing_multiplier = Globals.timing_ring.TIER_MULTIPLIERS.get(tier, 1.0)
					textbox.replace(tier.to_upper() + "!")
					await wait(LONG)

			else:
				var attacking_enemy := get_enemy_node(actor)

				if attacking_enemy:

					if payload is AttackData:
						attacking_enemy.current_queued_attack = payload
						await attacking_enemy.play_attack_animation()
						
					elif payload is Item:
						var spell := payload as Item

						attacking_enemy.current_queued_spell = spell
						await attacking_enemy.play_spell_animation()
						

					else:
						attacking_enemy.current_queued_attack = null
						await attacking_enemy.play_attack_animation()

			if hit:
				target.healhurt(damage)

				if payload is AttackData:
					var attack := payload as AttackData

					if attack.status_effect != null:
						var roll := randi_range(1, 100)

						if roll <= attack.status_chance:
							target.add_status(attack.status_effect)

							textbox.replace("%s is afflicted with %s!" % [
								target.name,
								attack.status_effect.display_name
							])

							await wait(LONG)

			if target_is_friendly:
				Globals.screen_shake.add_trauma()

			if !hit:
				textbox.replace("... but misses!")
			else:
				if critical:
					textbox.replace("CRITICAL! %s takes %d hit points in damage!!" % [
					target.name,
					abs(damage)
			])
				else:
					textbox.replace("%s takes %d hit points in damage!!" % [
					target.name,
					abs(damage)
				])
		Actions.MAGIC:

			var spell := payload as Item
			

			text += " casts %s!" % spell.display_name

			textbox.start("", [text])

			await wait(SHORT)
			var timing_multiplier := 1.5
			if Data.party.has(actor):
				Globals.battle_effects.play_spell(actor, spell)
				Globals.timing_ring.start()
				var tier: String = await Globals.timing_ring.completed
				timing_multiplier = Globals.timing_ring.TIER_MULTIPLIERS.get(tier, 1.0)
				textbox.replace(tier.to_upper() + "!")
				await wait(LONG)
			else:
				var attacking_enemy := get_enemy_node(actor)
				if attacking_enemy:
					attacking_enemy.current_queued_spell = spell
					await attacking_enemy.play_spell_animation()
			
			
			var spell_targets := get_spell_targets(actor, spell, target)
			
			var effective_power := int(round((spell.power + int(round(actor.get_magic_attack() * spell.power_scaling))) * timing_multiplier))
			var effective_heal := spell.heal + int(round(actor.get_magic_attack() * spell.heal_scaling))

			for spell_target: BattleActor in spell_targets:
				var mitigated_power := 0
				if effective_power != 0:
					mitigated_power = maxi(1, effective_power - spell_target.get_defense())
					spell_target.healhurt(-mitigated_power)

				if effective_heal != 0:
					spell_target.healhurt(effective_heal)

				if spell.status_effect != null:
					var roll := randi_range(1, 100)

					if roll <= spell.status_chance:
						spell_target.add_status(spell.status_effect)

						textbox.replace("%s is afflicted with %s!" % [
							spell_target.name,
							spell.status_effect.display_name
						])

						await wait(SHORT)
				if mitigated_power > 0:
					textbox.replace("%s takes %d damage!" % [
						spell_target.name,
						mitigated_power
					])
				if effective_heal > 0:
					textbox.replace("%s recovers %d HP!" % [
						spell_target.name,
						effective_heal
					])

				if effective_heal > 0:
					textbox.replace("%s recovers %d HP!" % [
						spell_target.name,
						effective_heal
					])
		Actions.ITEM:
			print("item used")
			var item := payload as Item
			
			
			if item == null and payload != null and "display_name" in payload:
				item = payload
			
			if item == null:
				print("CRITICAL: Failed to recognize the Item payload!")
				await run()
				return

			text += " uses " + item.display_name + "..."
			textbox.start("", [text])
			await wait(SHORT)

			var item_targets := get_spell_targets(actor, item, target)

			for item_target: BattleActor in item_targets:
				var before_hp := item_target.hp

				if item.power > 0:
					var mitigated := maxi(1, item.power - item_target.get_defense())
					item_target.healhurt(-mitigated)
				if item.heal > 0:
					item_target.healhurt(item.heal)

				if item.status_effect != null:
					var roll := randi_range(1, 100)
					if roll <= item.status_chance:
						item_target.add_status(item.status_effect)
						textbox.replace("%s is afflicted with %s!" % [
							item_target.name,
							item.status_effect.display_name
						])
						await wait(SHORT)

				var change := item_target.hp - before_hp
				if change < 0:
					textbox.replace("%s takes %d damage!" % [item_target.name, abs(change)])
				elif change > 0:
					textbox.replace("%s recovers %d HP!" % [item_target.name, change])
				elif change == 0:
					textbox.replace("%s is already full!" % [item_target.name])
			if Data.party.has(actor):
				Data.item_inventory.remove_item(item)

	await wait(LONG)
	await process_end_statuses(actor)
	var party_alive := false
	for member: BattleActor in Data.party:
		if not member.is_defeated():
			party_alive = true
			break

	if not party_alive:
		await get_parent().battle_lost()
		return
	if target.is_defeated():
		if target.death_quotes.size() > 0:
			textbox.replace(target.death_quotes.pick_random())
		else:
			textbox.replace(target.name + " loses the will to continue.")

		await wait(LONG)


	var any_enemies_alive := false

	for enemy: Enemy in get_node("../Enemies").get_buttons():
		if enemy.data and !enemy.data.is_defeated():
			any_enemies_alive = true
			break

	if !any_enemies_alive:
		var battle: Control = get_parent()

		await battle.battle_won()
		return

	await run()

func get_enemy_node(actor: BattleActor) -> Enemy:
	var enemy_menu = get_node("../Enemies")
	if enemy_menu and enemy_menu.has_method("get_buttons"):
		for enemy: Enemy in enemy_menu.get_buttons():
			print("Checking enemy: ", enemy.name, " data: ", enemy.data.name if enemy.data else "null")
			if enemy.data == actor:
				print("MATCH FOUND")
				return enemy
	print("get_enemy_node: NO MATCH for ", actor.name)
	return null
func _sort_by_speed(a: BattleActor, b: BattleActor) -> bool:
	if a.get_speed() == b.get_speed():
		return a.get_instance_id() < b.get_instance_id()

	return a.get_speed() > b.get_speed()

func play_player_attack_video(attack: AttackData) -> void:
	var player := get_node("../MainAttack") as VideoStreamPlayer

	if player == null:
		push_error("Couldn't find MainAttack!")
		return

	if attack == null or attack.attack_video == null:
		return

	player.stream = attack.attack_video

	player.show()
	player.stop()
	player.play()

	await player.finished

	player.stop()
	player.hide()
func build_turn_order(order: Array[BattleActor]) -> void:
	events.clear()

	var sorted_order := order.duplicate()

	sorted_order.sort_custom(_sort_by_speed)

	for actor: BattleActor in sorted_order:
		if actor.queued_action == -1:
			continue

		add(
			actor.queued_action,
			actor,
			actor.queued_target,
			actor.queued_payload
		)
func process_end_statuses(actor: BattleActor) -> void:
	for status in actor.statuses.duplicate():

		match status.type:

			StatusEffect.StatusType.BLEED:

				textbox.replace("%s bleeds!" % actor.name)
				await wait(SHORT)

				actor.healhurt(-int(status.potency))

				textbox.replace("%s takes %d damage!" % [
					actor.name,
					int(status.potency)
				])

				await wait(SHORT)

			StatusEffect.StatusType.BURN:

				textbox.replace("%s is burned!" % actor.name)
				await wait(SHORT)

				actor.healhurt(-int(status.potency))

				textbox.replace("%s takes %d damage!" % [
					actor.name,
					int(status.potency)
				])

				await wait(SHORT)

			StatusEffect.StatusType.POISON:

				textbox.replace("%s suffers poison!" % actor.name)
				await wait(SHORT)

				actor.healhurt(-int(status.potency))

				textbox.replace("%s takes %d damage!" % [
					actor.name,
					int(status.potency)
				])

				await wait(SHORT)

			StatusEffect.StatusType.REGEN:

				textbox.replace("%s regenerates!" % actor.name)
				await wait(SHORT)

				actor.healhurt(int(status.potency))

				textbox.replace("%s recovers %d HP!" % [
					actor.name,
					int(status.potency)
				])

				await wait(SHORT)

		status.turns -= 1

		if status.turns <= 0:
			textbox.replace("%s is no longer affected by %s." % [
				actor.name,
				status.display_name
			])

			await wait(SHORT)

			actor.remove_status(status.type)
func get_spell_targets(actor: BattleActor, spell: Item, fallback_target: BattleActor) -> Array[BattleActor]:
	var actor_is_friendly: bool = Data.party.has(actor)
	var result: Array[BattleActor] = []

	match spell.target:
		Item.TargetType.SELF:
			result.append(actor)

		Item.TargetType.ALL_ALLIES:
			if actor_is_friendly:
				for member: BattleActor in Data.party:
					if !member.is_defeated():
						result.append(member)
			else:
				for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
					if enemy.data and !enemy.data.is_defeated():
						result.append(enemy.data)

		Item.TargetType.ALL_ENEMIES:
			if actor_is_friendly:
				for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
					if enemy.data and !enemy.data.is_defeated():
						result.append(enemy.data)
			else:
				for member: BattleActor in Data.party:
					if !member.is_defeated():
						result.append(member)

		_:
			if fallback_target:
				result.append(fallback_target)

	return result
