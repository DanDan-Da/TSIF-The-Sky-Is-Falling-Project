extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Fade_transition/AnimationPlayer.play("fade_out")
	MenuMusic.stop()
