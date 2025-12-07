extends Area2D

var is_pickble = false

func _on_body_entered(body: Node2D) -> void:
	if is_pickble:
		return
	if body.name == "Player":
		is_pickble = true
		var tween = create_tween().set_parallel()
		tween.tween_property(self, "position", position - Vector2(0,25), 0.3)
		tween.tween_property(self, "modulate:a", 0, 0.3)
		tween.chain().tween_callback(queue_free)
		body.gold += 10


func _on_timer_timeout() -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "position", position - Vector2(0,-25), 0.3)
	tween.tween_property(self, "modulate:a", 0, 0.3)
	tween.chain().tween_callback(queue_free)
	
