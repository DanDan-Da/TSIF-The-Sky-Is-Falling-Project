extends Node3D

@export var spawn_range_x: Vector2 = Vector2(-4.5, 4.5)  # X range for spawning
@export var spawn_range_z: Vector2 = Vector2(-4.5, 4.5)  # Z range for spawning
@export var spawn_height: float = 20.0  # Y position for spawning
@export var initial_fall_impulse: float = 5.0  # Initial downward force
@export var spawn_interval: float = 8  # Time interval between spawns
@export var coin_scene: PackedScene = preload("res://coin_rigid.tscn")  # Preloaded scene for the coin

func _ready():
	randomize()  # Ensure randomness

	if coin_scene == null:
		push_error("coin_scene is not assigned or loaded! Check the path or Inspector.")
		return

	# Create and set up a timer for spawning coins
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	add_child(spawn_timer)
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))

func _on_spawn_timer_timeout() -> void:
	if coin_scene == null:
		push_error("coin_scene is not assigned!")
		return


	# Create a new coin instance
	var coin = coin_scene.instantiate()
	add_child(coin)

	# Set a random spawn position
	var spawn_position = Vector3(
		randf_range(spawn_range_x.x, spawn_range_x.y),
		spawn_height,
		randf_range(spawn_range_z.x, spawn_range_z.y)
	)
	coin.global_transform.origin = spawn_position

	# Apply physics if the coin is a RigidBody3D
	if coin is RigidBody3D:
		coin.linear_velocity = Vector3.ZERO
		coin.angular_velocity = Vector3.ZERO
		coin.apply_impulse(Vector3.ZERO, Vector3(0, -initial_fall_impulse, 0))

		# Add a timer to freeze physics after a delay
		var disable_timer = Timer.new()
		disable_timer.wait_time = 30
		disable_timer.one_shot = true
		coin.add_child(disable_timer)
		disable_timer.connect("timeout", Callable(self, "_disable_physics").bind(coin))
		disable_timer.start()

func _disable_physics(coin: RigidBody3D) -> void:
	coin.freeze = true
