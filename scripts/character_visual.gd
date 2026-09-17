class_name CharacterVisual
extends Node2D

# Assign a new SpriteFrames resource in the Inspector to replace all PNGs.
@export var idle_bob: bool = true
@onready var sprite: AnimatedSprite2D = $Sprite
var pose: String = "working"
var clock: float = 0.0

func set_pose(value: String) -> void:
	pose = value
	if sprite.sprite_frames.has_animation(value):
		sprite.play(value)

func _process(delta: float) -> void:
	clock += delta
	sprite.position.y = -2.0 if idle_bob and int(clock * 3.0) % 2 == 0 else 0.0
