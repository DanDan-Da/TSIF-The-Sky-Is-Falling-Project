extends Node3D

@export var spawn_interval: float = 0.8  #Initial time between spawns
@export var min_spawn_interval: float = 0.05 #Minimum allowed spawn interval
@export var interval_decrease: float = 0.1 #Amout to reduce intervaal every 30seconds 
@export var spawn_range_x: Vector2 = Vector2(-4.5, 4.5)  # X range for spawning
@export var spawn_range_z: Vector2 = Vector2(-4.5, 4.5)  # Z range for spawning
@export var spawn_height: float = 20.0  # Y position for spawning
@export var initial_fall_impulse: float = 10.  # Initial downward force

var spawn_timer: Timer  # Timer for spawning new objects
var interval_timer: Timer #Timer to adjust spawn intervals
var spawnable_objects: Array = []  # Array to hold the original spawnable objects
var initial_disable = 40 #time at first to disable physics 


func _ready():
	randomize()  # Ensure randomness
	initialize_spawnable_objects()
	setup_spawn_timer()
	setup_interval_timer()
	


# Initialize the spawnable objects array with the original children
func initialize_spawnable_objects():
	for child in get_children():
		spawnable_objects.append(child)

# Set up the spawn timer to create objects at regular intervals
func setup_spawn_timer():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	spawn_timer.connect("timeout", Callable(self, "spawn_object"))
	add_child(spawn_timer)
	spawn_timer.start()

# Set up the interval timer to decrease spawn interval every 10secs
func setup_interval_timer():
	interval_timer = Timer.new()
	interval_timer.wait_time = 10  # Adjust every 10secs
	interval_timer.autostart = true
	interval_timer.one_shot = false
	interval_timer.connect("timeout", Callable(self, "adjust_spawn_interval"))
	add_child(interval_timer)
	interval_timer.start()

# Function to spawn a random object at a random position
func spawn_object():
	if spawnable_objects.size() > 0:
		# Pick a random object to spawn from the original pool
		var random_child = spawnable_objects[randi() % spawnable_objects.size()]
		var new_object = random_child.duplicate() as Node3D  # Ensure it's a Node3D

		if new_object:
			add_child(new_object)

			# Set a random spawn position
			var spawn_position = Vector3(
				randf_range(spawn_range_x.x, spawn_range_x.y),  # Random X
				spawn_height,                                  # Spawn height
				randf_range(spawn_range_z.x, spawn_range_z.y)  # Random Z
			)
			new_object.global_transform.origin = spawn_position

			# If the new object is a RigidBody3D, apply physics
			if new_object is RigidBody3D:
				new_object.linear_velocity = Vector3.ZERO
				new_object.angular_velocity = Vector3.ZERO

				# Apply the initial downward impulse
				new_object.apply_impulse(Vector3.ZERO, Vector3(0, -initial_fall_impulse, 0))

				# Add a timer to disable physics after a delay
				var disable_timer = Timer.new()
				disable_timer.wait_time = initial_disable  # Time in seconds before disabling physics
				disable_timer.one_shot = true
				disable_timer.connect("timeout", Callable(self, "_disable_physics").bind(new_object))
				new_object.add_child(disable_timer)
				disable_timer.start()
#Making the objects freeze quicker the longer time goes

func _on_freeze_timer_timeout() -> void:
	if initial_disable > 10:
		initial_disable -= 5
		print("disabling physics 5 seconds faster")
		print(initial_disable)


# Function to disable physics for an object
func _disable_physics(object: RigidBody3D):
	if object and is_instance_valid(object):  # Use the global function correctly
		object.set_deferred("freeze", true)  # Freeze the rigid body in place
		
# Adjust the spawn interval every 30 seconds
func adjust_spawn_interval():
	if spawn_interval > min_spawn_interval:
		spawn_interval -= interval_decrease
		spawn_interval = max(spawn_interval, min_spawn_interval)  # Clamp to the minimum
		spawn_timer.wait_time = spawn_interval  # Update the spawn timer
		print("Spawn interval decreased to:", spawn_interval)


func _on_height_timer_timeout() -> void:
	spawn_height += 5
