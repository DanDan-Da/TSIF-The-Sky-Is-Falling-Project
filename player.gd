extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 5.25
const PUSH_FORCE = 1.0  # Adjust to control the strength of the push
const MIN_PUSH_FORCE = 0.5  # Minimum force applied when pushing
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")  # Retrieve default gravity setting
var last_direction = Vector3.FORWARD
var rotation_speed = 10  # Speed the character rotates
var health = 5
var is_hurt = false
var is_dead = false
var canstep = true  # To play step sound
var hearts_list : Array[TextureRect]

# Timer for periodic damage
var damage_timer: Timer
var is_in_hurtbox = false  # Track if the player is in the hurtbox

func _ready() -> void:
	var hearts_parent = $health_bar/HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	print(hearts_list)
	# Initialize the timer (Assuming the timer is a child of the player node)
	damage_timer = $DamageTimer  # Timer node should be added in the player scene
	# Connect the signal correctly with a Callable
	damage_timer.connect("timeout", Callable(self, "_on_damage_timer_timeout"))  # Correct Callable syntax
	damage_timer.stop()  # Ensure it's initially stopped

func hurt(hit_points):
	if !is_hurt:
		is_hurt = true
		$HurtTimer.start()
		print("HurtTimer Started")

		if hit_points < health:
			health -= hit_points
			$HurtSound.play()
			print("I'm hit")
		else:
			health = 0
		
		# Update the heart health bar
		update_heart_display()

		if health == 0:
			die()

func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health

func die():
	print("I'm dead")
	# Access the ScoreLabel node under Camera3D
	var score_label = $"../Camera3D/ScoreLabel"
	if score_label:
		# Store the current score in Global for the death screen
		Global.last_score = score_label.score
		
		# Update high score if applicable
		if score_label.score > Global.high_score:
			Global.high_score = score_label.score
			print("New high score: %d" % Global.high_score)
	$DeathTimer.start()
	$DeathSound.play()
	is_dead = true

func _on_damage_timer_timeout():
	# Apply damage every time the timer times out
	hurt(1)  # Apply 1 damage per interval

func _physics_process(delta: float) -> void:
	# Add gravity if the player is not on the floor
	if not is_on_floor():
		velocity.y -= gravity * delta  # Update only the Y component of the velocity

	# Handle jump input
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$Jump.play()

	# Get input direction for movement
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
		last_direction = direction  # Checks direction to use for rotation
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if canstep:
			$Step.play()
			$StepTimer.start()
			canstep = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	$PlayerMesh.rotation.y = lerp_angle($PlayerMesh.rotation.y, atan2(+last_direction.x, +last_direction.z), delta * rotation_speed)  # Rotation for character mesh
	$CollisionShape3D.rotation.y = lerp_angle($CollisionShape3D.rotation.y, atan2(+last_direction.x, +last_direction.z), delta * rotation_speed)  # Rotation for character hitbox

	# Move the character and apply the calculated velocity
	move_and_slide()

	# Handle pushing objects
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody3D:
			var push_force = (PUSH_FORCE * velocity.length() / SPEED) + MIN_PUSH_FORCE
			collision.get_collider().apply_central_impulse(-collision.get_normal() * push_force)

func _on_hurt_timer_timeout() -> void:
	is_hurt = false
	print("Hurt timer ended")

func _on_death_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://GameOver.tscn")

func _on_step_timer_timeout() -> void:
	canstep = true
