@tool
extends EditorPlugin


const CG_CommandScriptCollector = preload( "editor/utilities/command_script_collector.gd" )
const CG_EDITOR_ROOT = preload( "editor/root/cg_editor_root.tscn" )
const CG_EditorRoot = preload( "editor/root/cg_editor_root.gd" )

var command_editor_root: CG_EditorRoot = null
var command_editor_root_button: Button = null

var cg_singleton = null


func _enter_tree() -> void:
	
	if not has_node( "/root/CG_Singleton" ):
		add_autoload_singleton( "CG_Singleton", "res://addons/command_graph/cg_singleton.gd" )
	_initialize_cg_singleton.call_deferred()
	
	command_editor_root = CG_EDITOR_ROOT.instantiate( PackedScene.GEN_EDIT_STATE_DISABLED )
	command_editor_root_button = add_control_to_bottom_panel( command_editor_root, "Command Graph" )


func _exit_tree() -> void:
	
	if command_editor_root:
		remove_control_from_bottom_panel( command_editor_root )
		command_editor_root.queue_free()
	
	if is_instance_valid( cg_singleton ):
		remove_autoload_singleton( "CG_Singleton" )




func _handles( object ):
	
	return object is CG_Package


func _edit( object ):
	
	if object is CG_Package:
		if command_editor_root:
			
			if command_editor_root.edited_package == object:
				return
			
			command_editor_root.initialize( object as CG_Package )


func _make_visible( p_visible ):
	
	if p_visible:
		if command_editor_root:
			make_bottom_panel_item_visible( command_editor_root )


func _save_external_data():
	
	if command_editor_root and command_editor_root.get( "edited_package" ):
		
		var edited_package = command_editor_root.edited_package
		
		if ResourceLoader.exists( edited_package.resource_path ):
			ResourceSaver.save( edited_package, edited_package.resource_path )




func _initialize_cg_singleton() -> void:
	
	cg_singleton = get_node( "/root/CG_Singleton" )
	cg_singleton.plugin = self
	cg_singleton.command_editor_root = command_editor_root
