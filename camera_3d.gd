extends Camera3D
var move = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if move == true:
		position += Vector3(0,0.001,0)


func _on_move_timer_timeout() -> void:
	move = true
	print("camera movement start")
