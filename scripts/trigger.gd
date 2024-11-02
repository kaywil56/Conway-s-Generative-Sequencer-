extends Node2D

@onready var fill_sprite = $FillSprite2D

func _ready() -> void:
	fill_sprite.modulate.a = 0

func animate() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(fill_sprite, "modulate:a", .5, .125)
	tween.tween_property(fill_sprite, "modulate:a", 0, .25)
