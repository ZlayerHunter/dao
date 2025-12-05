extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var anim = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Move
	move_and_slide()

	# Animation logic
	update_animation(direction)


func update_animation(direction: float) -> void:
	# Jump has priority
	if velocity.y < 0 and not is_on_floor():
		play_anim("jump")
		return

	# Fall second priority
	if velocity.y > 0 and not is_on_floor():
		play_anim("fall")
		return

	# Run
	if direction != 0:
		play_anim("run")
		return

	# Idle
	play_anim("idle")


func play_anim(anim_name: String) -> void:
	# Чтобы не перезапускать анимацию каждый кадр
	if anim.animation != anim_name:
		anim.play(anim_name)
