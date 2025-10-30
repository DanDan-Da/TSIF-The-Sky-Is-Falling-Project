extends Control

var audio_server = AudioServer

func _ready():
	$VBoxContainer/MasterVSlider.value = db_to_value(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$VBoxContainer/MusicVSlider.value = db_to_value(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	$VBoxContainer/SFXVSlider.value = db_to_value(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	
	$VBoxContainer/MasterVSlider.connect("value_changed", Callable(self, "_on_MasterVSlider_value_changed"))
	$VBoxContainer/MusicVSlider.connect("value_changed", Callable(self, "_on_MusicVSlider_value_changed"))
	$VBoxContainer/SFXVSlider.connect("value_changed", Callable(self, "_on_SFXVSlider_value_changed"))

func _on_MasterVSlider_value_changed(value):
	audio_server.set_bus_volume_db(audio_server.get_bus_index("Master"), value_to_db(value))

func _on_MusicVSlider_value_changed(value):
	audio_server.set_bus_volume_db(audio_server.get_bus_index("Music"), value_to_db(value))

func _on_SFXVSlider_value_changed(value):
	audio_server.set_bus_volume_db(audio_server.get_bus_index("SFX"), value_to_db(value))
	$SoundTest.play()

func value_to_db(value):
	return 20 * log(value / 100.0) / log(10) if value > 0 else -80

func db_to_value(db):
	return pow(10, db / 20) * 100

func _on_title_screen_pressed() -> void:
	$Click.play()
	get_tree().change_scene_to_file("res://title_screen.tscn")
