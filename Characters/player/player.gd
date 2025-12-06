extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const INVUL_TIME = 0.7
const KNOCKBACK_FORCE = 0

@onready var anim = $AnimatedSprite2D

var health = 100
var is_alive = true
var is_hurt = false
var is_attacking = false
var enemies_in_attack_area = []

func _physics_process(delta):
	if not is_alive:
		return
	
	if is_attacking:
		move_and_slide()
		return
		
	if not is_hurt:
		if Input.is_action_just_pressed("Attack"):
			perform_attack()
			return
		player_movement(delta)

	move_and_slide()


func player_movement(delta):
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal
	var dir = Input.get_axis("MoveLeft", "MoveRight")

	
	if dir != 0:
		velocity.x = dir * SPEED
		anim.flip_h = dir < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation(dir)


func perform_attack():
	is_attacking = true
	velocity.x = 0  # игрок не двигается во время атаки

	anim.play("attack")

	# ждём конца анимации атаки
	await anim.animation_finished
	deal_damage()
	is_attacking = false

func deal_damage():
	for enemy in enemies_in_attack_area:
		if enemy and enemy.has_method("apply_damage"):
			enemy.apply_damage(34)


func update_animation(dir):
	if is_hurt:
		play_anim("take_hit")
		return

	if velocity.y < 0 and not is_on_floor():
		play_anim("jump")
		return

	if velocity.y > 0 and not is_on_floor():
		play_anim("fall")
		return

	if dir != 0:
		play_anim("run")
		return
	
	if is_attacking:
		return
	
	play_anim("idle")


func play_anim(name_anim):
	if anim.animation != name_anim:
		anim.play(name_anim)


# ======== ТУТ МАГИЯ HOLLOW KNIGHT =========

func apply_damage(amount: int):
	if is_hurt or not is_alive:
		return
	
	health -= amount
	
	if health <= 0:
		die()
		return
	
	start_hurt()


func start_hurt():
	is_hurt = true
	play_anim("take_hit")
	await anim.animation_finished
	is_hurt = false


func die():
	is_alive = false
	velocity = Vector2.ZERO
	anim.play("death")
	await anim.animation_finished
	queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		return
	if not enemies_in_attack_area.has(body):
			enemies_in_attack_area.append(body)


func _on_attack_area_body_exited(body: Node2D) -> void:
	if enemies_in_attack_area.has(body):
		enemies_in_attack_area.erase(body)
