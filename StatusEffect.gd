class_name StatusEffect
extends Resource
enum StatusType {
	BLEED,
	BURN,
	POISON,
	REGEN,

	SLOW,
	HASTE,

	BLIND,
	EVASION_UP,

	ATTACK_UP,
	ATTACK_DOWN,

	DEFENSE_UP,
	DEFENSE_DOWN,

	SLEEP,
	FEAR,
	STUN
}
@export var display_name: String = ""
@export var type: StatusType
@export var turns : int
@export var potency : float
@export var icon: Texture2D
