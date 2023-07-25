@tool
extends Tree


const CommandScriptCollector := preload( "res://addons/command_graph/editor/utilities/command_script_collector.gd" )


signal command_chosen( command_name: String, command_script_path: String )


var _command_script_map: Dictionary = {}
var _item_map: Dictionary = {}



func _ready() -> void:
	
	if get_tree().edited_scene_root == self:
		return
	
	refresh()



func refresh() -> void:
	
	_reload_command_list()
	_reconstruct_tree()





func _reconstruct_tree() -> void:
	
	clear()
	
	var root_item = create_item()
	root_item.set_text( 0, "Commands" )
	root_item.set_selectable( 0, false )
	root_item.set_meta( &"command_script_path", "" )
	
	_construct_items_recursively( root_item, _command_script_map )


static func _construct_items_recursively( parent_item: TreeItem, map: Dictionary ) -> Array [TreeItem]:
	
	var items: Array [TreeItem] = []
	var keys = map.keys()
	
	for key in keys:
		var value = map[key]
		
		match typeof( value ):
			
			# Handle a category
			TYPE_DICTIONARY:
				var category_item = parent_item.create_child()
				category_item.set_text( 0, key )
				category_item.set_selectable( 0, false )
				category_item.set_meta( &"command_script_path", "" )
				items.append_array( _construct_items_recursively( category_item, value ) )
			
			# Or handle a command script
			TYPE_STRING:
				var command_item = parent_item.create_child()
				command_item.set_text( 0, key )
				command_item.set_selectable( 0, true )
				command_item.set_meta( &"command_script_path", value )
				items.append( command_item )
	
	return items





func _reload_command_list() -> void:
	
	CommandScriptCollector.get_command_script_categorized_map( false, _command_script_map )



func _on_item_activated():
	
	var currently_selected_item = get_selected()
	
	if is_instance_valid( currently_selected_item ):
		
		var item_name = currently_selected_item.get_text( 0 )
		var item_script_path = currently_selected_item.get_meta( &"command_script_path", "NONE" )
		
		if ResourceLoader.exists( item_script_path, "Script" ):
			command_chosen.emit( item_name, item_script_path )
