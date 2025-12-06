extends CharacterBody2D

var speed = 100
var is_chase = false
var is_attack = false
var is_alive = true
var player_in_attack_area = false
var attack_started = false
var health = 100
@onready var anim = $AnimatedSprite2D
@onready var health_label = $HealthLabel

func _physics_process(delta):
	health_label.text = "HP: " + str(health)
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var player = $"../../Player/Player"
	var dir = (player.position - self.position).normalized()

	if not is_alive:
		return
		
	if is_attack or attack_started:
		attack_started = true
		anim.play("attack")
		await anim.animation_finished
		attack_started = false
		if player_in_attack_area and is_alive:
			player.apply_damage(20)
		velocity.x = 0
		move_and_slide()
		return

	if is_chase:
		velocity.x = dir.x * speed
		anim.play("run")
		anim.flip_h = dir.x < 0
	else:
		velocity.x = 0
		anim.play("idle")

	move_and_slide()

# ====== Триггер погони ======
func _on_detector_body_entered(body):
	if body.name == "Player":
		is_chase = true

func _on_detector_body_exited(body):
	if body.name == "Player":
		is_chase = false

# ====== Триггер атаки ======
func _on_detector_attack_body_entered(body):
	if body.name == "Player":
		is_attack = true

func _on_detector_attack_body_exited(body):
	if body.name == "Player":
		is_attack = false

# ====== Нанесение урона ======
func _on_attack_area_body_entered(body):
	if body.name == "Player":
		player_in_attack_area = true

func apply_damage(damage: int):
	health -= damage
	if health <1:
		die()

func die():
	is_alive = false
	anim.play("death")
	await anim.animation_finished
	queue_free()


func _on_dearh_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.velocity.y -= 200
		die()


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_attack_area = false
