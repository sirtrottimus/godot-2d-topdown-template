@tool
extends Area2D
class_name HitBox

@export var change_hp: int = 0

func _init() -> void:
  monitorable = true
  monitoring = false
  collision_mask = 0
  z_index = -1
