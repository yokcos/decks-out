extends Sprite2D


func pulse():
	var tween = create_tween()
	var target_angle = .2
	if randf() < .5:
		target_angle *= -1
	
	tween.tween_property( self, "scale", Vector2(1.4, 1.4), .1 )
	tween.parallel().tween_property( self, "rotation", target_angle, .1 )
	tween.parallel().tween_property( self, "z_index", 1, .1 )
	tween.tween_property( self, "scale", Vector2(1, 1), .9 )
	tween.parallel().tween_property( self, "rotation", 0, .9 )
	tween.parallel().tween_property( self, "z_index", 0, .9 )
