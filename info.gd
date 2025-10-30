extends Node2D
@onready var Fade_trasition =$Fade_transition
func _ready():
	$Fade_transition.hide()  # Hide the fade transition at the start


#Skip to game when space is pressed
#func _physics_process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#get_tree().change_scene_to_file("res://level_1.tscn")
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://level_1.tscn")
		
	
# Called when the video finishes
func _on_VideoStreamPlayer_finished():
	$Fade_transition.show()  # Show the fade effect
	$Fade_transition/AnimationPlayer.play("fade_in")

# Handle fade-out completion
func _on_fade_timer_timeout():
	pass

func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_file("res://level_1.tscn")
