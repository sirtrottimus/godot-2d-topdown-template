@tool
extends Area2D
class_name InteractionArea

func _init() -> void:
  monitorable = false
  monitoring = true
  collision_layer = 0
  collision_mask = 8
  z_index = -1
