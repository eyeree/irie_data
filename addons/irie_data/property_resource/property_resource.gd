@tool
class_name PropertyResource
extends Resource

var property_name:String

static func _get_variant_type_string(type:Variant.Type) -> String:
    # TODO: Variant.Type.keys()[type]
    return str(type)

# Virtual methods that should be overridden in derived classes. The ones that
# refer to the property type are commented out. If generic classes are ever
# supported, one could be used here.

func set_prop(prop:Dictionary, prop_options:Dictionary) -> String:
    push_error('must override set_prop in PropertyResource derived class')
    return ''

func delete_all_rows() -> void:
    push_error('must override delete_all_rows in PropertyResource derived class')

func delete_row(row_index:int) -> void:
    push_error('must override delete_row in PropertyResource derived class')
    
# func get_value(row_index:int) -> T:
#     push_error('must override get_value in PropertyResource derived class')

# func set_value(row_index:int, new_value:T) -> void:
#     push_error('must override set_value in PropertyResource derived class')
