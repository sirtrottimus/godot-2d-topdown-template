@tool
extends Area2D
class_name HurtBox

@export var health_controller: HealthController
@export_group("States")
@export var on_hp_increase: State ## State to enable when hp increase.
@export var on_hp_decrease: State ## State to enable when hp decrease.

func _init() -> void:
	monitorable = false
	monitoring = true
	collision_layer = 0
	z_index = -1

func _ready() -> void:
	area_entered.connect(_on_hitbox_entered)

func _on_hitbox_entered(hitbox: HitBox):
	if !hitbox or !health_controller:
		return
	var value = hitbox.change_hp
	if value < 0 and on_hp_decrease:
			on_hp_decrease.enable()
	if value > 0 and on_hp_increase:
			on_hp_increase.enable()
	health_controller.change_hp(hitbox.change_hp, hitbox.owner.name)
