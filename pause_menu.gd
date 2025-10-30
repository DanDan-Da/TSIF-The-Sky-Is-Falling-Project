extends Control

func _ready():
	$AnimationPlayer.play("RESET")


func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	$Click.play()
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()
		$Click.play()

func _on_resume_pressed():
	$Click.play()
	resume()

func _on_restart_pressed():
	resume()
	$Restart.start()
	$Click.play()



func _on_quit_pressed():
	$Quit.start()
	$Click.play()


func _process(delta):
	testEsc()


func _on_restart_timeout() -> void:
	get_tree().reload_current_scene()


func _on_quit_timeout() -> void:
	get_tree().quit()


func _on_title_screen_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://title_screen.tscn")
