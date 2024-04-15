extends Control

@onready var animation = $AnimationPlayer
var started = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey:
		if event.pressed and !started:
			started = true
			animation.play("start")
			await animation.animation_finished
			get_tree().change_scene_to_file("res://scene/world.tscn")
