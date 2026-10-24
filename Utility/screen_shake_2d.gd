class_name ScreenShake2D extends Camera2D

@export var decay: = 1.0
@export var max_offset := Vector2(40, 20)
@export var max_roll := 0.15
@export var noise: FastNoiseLite

var noise_y = 0
var trauma := 0.0
var trauma_pwr := 1

func _ready():
	
	Globals.screen_shake = self
	
	
	
func _process(delta):
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0)
		_shake()
	else:
		offset = Vector2.ZERO
		rotation = 0.0
		enabled = false
		
func _shake() -> void:
	var amt = pow(trauma, trauma_pwr)
	noise_y += 0.5
	rotation = max_roll * amt * noise.get_noise_2d(noise.seed,noise_y)
	offset.x = max_offset.x * amt * noise.get_noise_2d(noise.seed*2,noise_y)
	offset.y = max_offset.y * amt * noise.get_noise_2d(noise.seed*3,noise_y)



func add_trauma(amount: float = 0.5) -> void:
	if !enabled:
		enabled = true

	trauma = min(trauma + amount, 1.0)
