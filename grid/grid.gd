extends RefCounted
class_name Grid


var cells: Dictionary = {}
var units: Dictionary = {}
var hps: Dictionary = {}

signal unit_died
signal unit_moved
signal unit_added
signal unit_attacked
signal unit_damaged
signal cell_damage
signal debug_message


# -------- -------- -------- -------- SETUP -------- -------- -------- --------

func setup_team( team: int, hp: float ):
	if !hps.has(team):
		hps[team] = hp

# -------- -------- -------- -------- CELLS -------- -------- -------- --------

func get_cell( where: Vector2i ):
	if cells.has(where):
		return cells[where]
	return null

func add_cell( where: Vector2i, team: int ):
	if !cells.has( where ):
		var new_cell = Cell.new()
		new_cell.position = where
		new_cell.team = team
		
		cells[where] = new_cell
		return true
	return false

func add_cell_rectangle( start: Vector2i, end: Vector2i, team: int ):
	for i in range(start.x, end.x+1):
		for j in range(start.y, end.y+1):
			add_cell( Vector2i(i, j), team )

# -------- -------- -------- -------- TURNS -------- -------- -------- --------

func resolve_turn():
	for this_unit in units.values():
		this_unit.resolve_turn()
	deal_cell_damage()
	exorcise_units()

# -------- -------- -------- -------- UNITS -------- -------- -------- --------

func get_unit( where: Vector2i ) -> UnitInstance:
	if units.has(where):
		return units[where]
	return null

func add_unit( where: Vector2i, what: Unit ):
	if !units.has( where ):
		var new_unit = what.instantiate()
		
		units[where] = new_unit
		new_unit.position = where
		new_unit.connect_to_grid( self )
		
		output_message("Adding unit %s at %s" % [what.name, where])
		unit_added.emit( where, new_unit )
		return new_unit
	return null

func push_unit( where: Vector2i, by: Vector2i, move_power: int = 1 ):
	var to = where + by
	
	if get_unit( to ):
		if move_power > 1:
			if units.has(where):
				var result = push_unit( to, by, move_power-1 )
				if !result:
					output_message( "Failed to push unit %s at %s to %s" % [units[where].unit.name, where, where+by] )
					return false
	
	return move_unit( where, to )

func move_unit(from: Vector2i, to: Vector2i):
	var this_unit = get_unit( from )
	
	if get_unit( to ):
		return false
	if !this_unit:
		return false
	if !get_cell(to) and !this_unit.flying:
		return false
	
	output_message( "Successfully moving unit %s from %s to %s" % [this_unit.unit.name, from, to] )
	this_unit.position = to
	units[to] = this_unit
	units.erase(from)
	unit_moved.emit( from, to )
	return true

# -------- -------- -------- -------- DAMAGE -------- -------- -------- --------

func deal_damage( where: Vector2i, dmg: DamageInstance ):
	if units.has(where):
		output_message( "Damaging unit %s at %s by %s" % [units[where].unit.name, where, dmg.damage] )
		units[where].take_damage(dmg)
		unit_damaged.emit( where, dmg )
	elif cells.has(where):
		var this_team = cells[where].team
		deal_direct_damage( this_team, dmg )
		output_message( "Dealing direct damage of %s to %s" % [dmg.damage, where] )

func deal_direct_damage( team: int, dmg: DamageInstance ):
	if hps.has(team):
		hps[team] -= dmg.damage

func deal_cell_damage():
	var positions = units.keys().duplicate()
	positions.sort_custom( sort_cells )
	var dmg: DamageInstance = DamageInstance.new()
	dmg.damage = 1
	
	for pos in positions:
		if cells.has(pos):
			var this_unit: UnitInstance = units[pos]
			var this_cell: Cell = cells[pos]
			if this_unit.team != this_cell.team:
				deal_damage( pos, dmg )
				cell_damage.emit( pos )
				unit_damaged.emit( pos, dmg )

func exorcise_units():
	var positions = units.keys().duplicate()
	positions.sort_custom( sort_cells )
	for pos in positions:
		var this_unit: UnitInstance = units[pos]
		if this_unit.hp <= 0:
			output_message( "Unit %s at %s has perished" % [units[pos].unit.name, pos] )
			units.erase( pos )
			unit_died.emit( pos )

# -------- -------- -------- --------               -------- -------- -------- --------

# -------- -------- -------- -------- MISCELLANEOUS -------- -------- -------- --------

# -------- -------- -------- --------               -------- -------- -------- --------

func output_message(what):
	debug_message.emit( what )

func sort_cells( a: Vector2i, b: Vector2i ) -> bool:
	if b.y > a.y:
		return true
	return b.x > a.x

# -------- -------- -------- -------- EVENTS -------- -------- -------- --------

func _on_attack_dealt( from: Vector2i, relative: Vector2i, dmg: DamageInstance ):
	unit_attacked.emit( from, relative, dmg )
	deal_damage( from+relative, dmg )

func _on_unit_slain( where: Vector2i ):
	pass
