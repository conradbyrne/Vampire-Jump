extends Area2D
signal coin_collected(value)
@export var value := 1000

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body == self.get_parent().get_node("../Player") or body.name == "Player":
		emit_signal("coin_collected", value)
		queue_free()
