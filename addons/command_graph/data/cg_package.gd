@tool
class_name CG_Package
extends Resource
## Package of all the on-disk data for an escoria event


signal sequence_added( p_sequence_id: String )
signal sequence_removed( p_sequence_id: String )


const PROPERTY_SEQUENCES: Dictionary = {
	"type": TYPE_DICTIONARY,
	"name": "_sequences",
	"hint": PROPERTY_HINT_NONE,
	"hint_string": "",
	"usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_NO_EDITOR,
}


var _sequences: Dictionary = {}




func _get_property_list():
	
	var properties = []
	
	properties.append( PROPERTY_SEQUENCES )
	
	return properties




func has_sequence( p_sequence_id: String ) -> bool:
	
	return _sequences.has( p_sequence_id )


func get_sequence( p_sequence_id: String ) -> CG_Sequence:
	
	if not has_sequence( p_sequence_id ):
		return null
	
	return _sequences[p_sequence_id] as CG_Sequence


func get_sequences() -> Array [CG_Sequence]:
	
	var sequences: Array [CG_Sequence] = []
	sequences.assign( _sequences.values() )
	
	return sequences


func create_sequence( p_sequence_id: String ) -> CG_Sequence:
	
	if p_sequence_id.is_empty() or has_sequence( p_sequence_id ):
		printerr( "Can't create this sequence." )
		return null
	
	var sequence := CG_Sequence.new()
	sequence.set_id( p_sequence_id )
	_sequences[p_sequence_id] = sequence
	
	sequence_added.emit( p_sequence_id )
	
	return sequence


func erase_sequence( p_sequence_id: String ) -> bool:
	
	if p_sequence_id.is_empty() or not has_sequence( p_sequence_id ):
		return false
	
	_sequences.erase( p_sequence_id )
	sequence_removed.emit( p_sequence_id )
	return true
