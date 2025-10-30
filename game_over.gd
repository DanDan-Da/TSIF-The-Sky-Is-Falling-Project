extends Node2D
var button_type = null


func _on_try_again_pressed() -> void:
	button_type = "try"
	$Click.play()
	$Fade_transition.show()
	$Fade_transition/Fade_timer.start()
	$Fade_transition/AnimationPlayer.play("fade_in")

# Called when the quit button is pressed.
func _on_quit_pressed():
	button_type = "quit"
	$Click.play()
	$Fade_transition.show()
	$Fade_transition/Fade_timer.start()
	$Fade_transition/AnimationPlayer.play("fade_in")


func _on_title_screen_pressed() -> void:
	button_type = "title"
	$Click.play()
	$Fade_transition.show()
	$Fade_transition/Fade_timer.start()
	$Fade_transition/AnimationPlayer.play("fade_in")


# Called when the fade timer times out.
func _on_fade_timer_timeout() -> void:
	if button_type == "try":
		get_tree().change_scene_to_file("res://level_1.tscn")
	if button_type == "quit":
		get_tree().quit()
	if button_type == "title":
		get_tree().change_scene_to_file("res://title_screen.tscn")
	else:
		return
