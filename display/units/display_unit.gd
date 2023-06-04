extends Node2D


var unit: UnitInstance = null : set = set_unit
@onready var sprite: Sprite2D = $sprite

var tween_active: bool = false
var tween_queue = []


func _process(delta):
	unqueue_tween()


func set_unit( what: UnitInstance ):
	unit = what
	
	if unit:
		$sprite.texture = unit.unit.sprite

func queue_tween( what: Tween ):
	what.stop()
	tween_queue.append( what )

func unqueue_tween():
	if !tween_active and tween_queue.size() > 0:
		var this_tween: Tween = tween_queue.pop_front()
		this_tween.play()
		this_tween.finished.connect( _on_tween_finished )
		tween_active = true

func attack( where: Vector2 ):
	var tween := create_tween()
	tween.set_trans( Tween.TRANS_CUBIC )
	
	tween.tween_property( sprite, "position", -where*.1, .4 )
	tween.parallel().tween_property( sprite, "scale", Vector2( 1.5, 1.5 ), .4 )
	
	tween.set_ease( Tween.EASE_IN )
	tween.tween_property( sprite, "position", where, .1 )
	tween.parallel().tween_property( sprite, "scale", Vector2( 1, 1 ), .1 )
	
	tween.set_ease( Tween.EASE_OUT )
	tween.tween_property( sprite, "position", Vector2(), .5 )
	
	queue_tween( tween )

func take_damage( dmg: DamageInstance, shake_vector: Vector2 = Vector2(8, 0) ):
	var tween := create_tween()
	var tween_col = tween.parallel()
	
	tween.set_trans( Tween.TRANS_CUBIC )
	tween_col.tween_property( sprite, "modulate", Color(5, 5, 5, 1), .1 )
	var pt := tween.tween_property( sprite, "position", shake_vector, .1 )
	pt.set_ease( Tween.EASE_OUT )
	
	tween_col.tween_property( sprite, "modulate", Color(1, 1, 1, 1), .3 )
	tween.tween_property( sprite, "position", -shake_vector*.5, .2 )
	tween.tween_property( sprite, "position", Vector2(), .1 )
	
	queue_tween( tween )

func die():
	queue_free()


func _on_tween_finished():
	tween_active = false
