@tool
class_name PropertyResourceEnum
extends PropertyResource

@export_storage var data:PackedByteArray = []
@export_storage var enum_name:String = ''

static func is_enum_prop(prop:Dictionary):
    return false

static func for_prop(prop:Dictionary, prop_options:Dictionary, default_value:Variant, row_count:int) -> PropertyResourceEnum:
    var resource:PropertyResourceEnum = PropertyResourceEnum.new()
    resource.property_name = prop['name']
    resource.enum_name = prop['class_name']
    if row_count > 0:
        resource.data.resize(row_count)
        if resource.data[0] != default_value:
            for i:int in row_count:
                resource.data[i] = default_value
    return resource

func get_value(row_index:int) -> float:
    return data[row_index]

func set_value(row_index:int, new_value:float) -> void:
    data[row_index] = new_value

func delete_row(row_index:int) -> void:
    data.remove_at(row_index)

func delete_all_rows() -> void:
    data.clear()

func set_prop(prop:Dictionary, prop_options:Dictionary) -> String:
    if (prop['usage'] & PROPERTY_USAGE_CLASS_IS_ENUM) == 0:
        return 'Expected enum property'

    if prop['type'] != TYPE_INT:
        return 'Expected property type int (for enum) but property had type %s' % _get_variant_type_string(prop['type'])

    if prop['class_name'] != enum_name:
        return 'Expected property enum type %s but property had enum type %s' % prop['class_name']

    property_name = prop['name']

    return ''
