extends Node

const GAME_SIZE: Vector2 = Vector2(1280,720)
const GAME_SIZE_HALVED: Vector2 = GAME_SIZE * 0.5
const CELL_SIZE: Vector2 = Vector2(16,16)
const NULL_CELL: Vector2 = Vector2(-9999,-9999)

var cursor: Node = null
var current_map: TileMapLayer = null
var target_cell: Vector2 = Vector2.ZERO


var battle_effects: BattleEffects = null


var textbox: Textbox = null
var camera: Camera2D = null
var screen_shake: ScreenShake2D = null
var shop_screen: ShopScreen = null
var danger_overlay: DangerOverlay = null
var cell_size: Vector2 = Vector2.ZERO
var event_log: Label = null
var banter_box: BanterBox = null
var music_position: float = 0.0
var state: int = 0
var bestiary: Bestiary = null
var menu_has_focus: bool = false 
var timing_ring: TimingRing = null
var location_banner: LocationBanner = null
var tip_screen: TipScreen = null
var game_over_screen: GameOverScreen = null
func _ready() -> void:
	randomize()
	process_mode = PROCESS_MODE_ALWAYS
