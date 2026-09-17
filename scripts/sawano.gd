extends CharacterVisual

var celebration_remaining: float = 0.0

func celebrate(banana: bool) -> void:
	celebration_remaining = 0.7 if banana else 0.42
	set_pose("happy" if banana else "steal")

func reset() -> void:
	celebration_remaining = 0.0
	set_pose("working")

func _process(delta: float) -> void:
	super._process(delta)
	if celebration_remaining > 0.0:
		celebration_remaining -= delta
		if celebration_remaining <= 0.0: set_pose("working")
