extends Node2D


var grid: Grid = null : set = set_grid
var cell_size := Vector2i(64, 64)
var team_cells = {
	0: preload("res://display/zone_neutral.png"),
	1: preload("res://display/zone_player.png"),
	2: preload("res://display/zone_enemy.png"),
}
var cells = {}
var units = {}
var unresolved_turns = 0
var animating: bool = false
var animation_queues := []
var current_queue: int = 0
var current_animations := []
enum {
	ANIM_ATTACC,
	ANIM_CELL_DAMAGE,
	ANIM_DEATH,
}

const obj_unit = preload("res://display/units/display_unit.tscn")
const obj_cell = preload("res://display/display_cell.tscn")




func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var relative_mouse_position = get_global_mouse_position() - global_position
		relative_mouse_position /= Vector2(cell_size)
		var this_cell: Vector2i = relative_mouse_position.round()
		grid.add_unit( this_cell, load("res://units/units/knave.tres") )


func add_cell( where: Vector2i, team: int ):
	var new_cell = obj_cell.instantiate()
	$cells.add_child( new_cell )
	new_cell.position = where * cell_size
	if team_cells.has( team ):
		new_cell.texture = team_cells[team]
	
	if cells.has( where ):
		push_error( "Display Grid attempts to deploy a cell at %s, when there already is one" % where )
	cells[where] = new_cell

func add_unit( where: Vector2i, unit: UnitInstance ):
	var new_unit = obj_unit.instantiate()
	$units.add_child( new_unit )
	new_unit.position = where * cell_size
	new_unit.unit = unit
	
	if units.has( where ):
		push_error( "Display Grid attempts to deploy unit %s at %s, when there already is one" % [unit.unit.name, where] )
	units[where] = new_unit

func move_unit( from: Vector2i, to: Vector2i ):
	if !units.has( from ):
		push_error( "Display Grid attempts to move a nonexistent unit from %s" % from )
		return false
	if units.has( to ):
		push_error( "Display Grid attempts to move a unit to occupied space %s" % to )
		return false
	
	var unit: Node2D = units[from]
	unit.position = to * cell_size
	units[to] = unit
	units.erase( from )


func set_grid( what: Grid ):
	grid = what
	
	for pos in grid.cells:
		var this_cell: Cell = grid.cells[pos]
		add_cell( pos, this_cell.team )
	for pos in grid.units:
		var this_unit: UnitInstance = grid.units[pos]
		add_unit( pos, this_unit )
	
	grid.unit_added.connect( _on_unit_added )
	grid.unit_moved.connect( _on_unit_moved )
	grid.unit_died.connect( _on_unit_slain )
	grid.unit_attacked.connect( _on_unit_attacked )
	grid.unit_damaged.connect( _on_unit_damaged )
	grid.cell_damage.connect( _on_cell_damage )
	grid.turn_ended.connect( _on_turn_ended )

# -------- -------- -------- -------- ANIMATIONS -------- -------- -------- --------

func destroy_unit( where: Vector2i ):
	units[where].die()
	units.erase( where )

func perform_attack( attacker: Vector2i, where: Vector2i ):
	if units.has( attacker ):
		var this_unit = units[attacker]
		var tween := create_tween()
		this_unit.attack_start( tween, where * cell_size )
		
		var target := attacker + where
		if units.has( target ):
			var target_unit = units[target]
			tween.tween_callback( target_unit.take_damage.bind(DamageInstance.new()) )
		
		this_unit.attack_end( tween )
		this_unit.queue_tween( tween )
		
		return tween

func add_animation( queue: int, function: Callable ):
	while animation_queues.size() < queue+1:
		animation_queues.append([])
	animation_queues[queue].append( function )

func pause_animation( time: float ):
	$animation_timer.start( time )
	$animation_timer.wait_time = .1

# -------- -------- -------- -------- EVENTS -------- -------- -------- --------

func _on_unit_added( where: Vector2i, unit: UnitInstance ):
	add_unit( where, unit )

func _on_unit_moved( from: Vector2i, to: Vector2i ):
	move_unit( from, to )

func _on_unit_slain( where: Vector2i ):
	if units.has( where ):
		add_animation( ANIM_DEATH, destroy_unit.bind( where ) )

func _on_unit_attacked( from: Vector2i, where: Vector2i, dmg: DamageInstance ):
	var relative_vector := Vector2( where )
	add_animation( ANIM_ATTACC, perform_attack.bind(from, relative_vector) )

func _on_unit_damaged( where: Vector2i, dmg: DamageInstance ):
	if units.has( where ) and false:
		var shake_vector = Vector2(8, 0).rotated( randf() * PI*2 )
		#animation_queue.append( units[where].take_damage.bind(dmg, shake_vector) )

func _on_cell_damage( where: Vector2i ):
	add_animation( ANIM_CELL_DAMAGE, cells[where].pulse )
	var shake_vector = Vector2(8, 0).rotated( randf() * PI*2 )
	add_animation( ANIM_CELL_DAMAGE, units[where].take_damage.bind(DamageInstance.new(), shake_vector) )

func _on_display_unit_slain( where: Vector2i ):
	if units.has( where ):
		units.erase( where )

func _on_attack_dealt( dmg: DamageInstance, where: Vector2i, attacking_unit: Vector2i ):
	if units.has( attacking_unit+where ):
		units[ attacking_unit+where ].take_damage( dmg )

func _on_turn_ended():
	unresolved_turns += 1
	animating = true


func _on_animation_timer_timeout():
	if unresolved_turns > 0:
		animating = true
	if !animating:
		return false
	if current_queue > animation_queues.size()-1:
		animating = false
		current_queue = 0
		unresolved_turns -= 1
		return false
	
	var this_queue = animation_queues[current_queue]
	if this_queue.size() > 0:
		var this_animation: Callable = this_queue.pop_front()
		if is_instance_valid( this_animation.get_object() ):
			var result = this_animation.call()
			if result is Tween:
				current_animations.append(result)
				result.finished.connect( _on_animation_finished.bind(result) )
	else:
		current_queue += 1

func _on_animation_finished( what: Tween ):
	if current_animations.has( what ):
		current_animations.erase( what )
		if current_animations.size() <= 0:
			print("Finishing animation queue")
			current_queue += 1
