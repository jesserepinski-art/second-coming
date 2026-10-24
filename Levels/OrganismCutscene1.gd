extends CutsceneDirector
@onready var dama: CutsceneActor = $"../Player/CutsceneActor"
@onready var mark: Marker2D = $"../CutsceneMarks/MarkA"
@onready var follower: CutsceneActor = $"../PartyFollower/CutsceneActor"
@onready var animationplayer: AnimationPlayer = $"../EyesAnimation"
@onready var sound: AudioStreamPlayer = $"../EyesAnimation/AudioStreamPlayer"
func _run() -> void:
	await say(0)
	await say_with(1, [move.bind(follower, mark.global_position)])
	await say(2)
	await say(3)
	animationplayer.play("watched")
	sound.play()
	await say(4)
	await say(5)
	await say(6)
	await TransitionManager.fade_to_black()
	await TransitionManager.fade_from_black()
	StoryFlags.set_flag("being_watched")
