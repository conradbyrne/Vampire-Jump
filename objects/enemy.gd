extends Area2D
@export var speed := 100.0
@export var direction := Vector2(1, 0)

func _ready():
    connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
    position += direction * speed * delta

func _on_body_entered(body):
    if body.name == "Player":
        get_tree().reload_current_scene()
