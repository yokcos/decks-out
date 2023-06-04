extends Control


var piece: Piece = null


func _ready():
	set_piece( load("res://pieces/pieces/bag_of_knaves.tres") )


func set_piece( what: Piece ):
	piece = what
	
	$list/title.text = "[center]%s" % what.title
	$list/image.texture = what.image
	$list/description.text = "[center]%s" % what.description
