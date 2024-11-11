@tool
class_name PropertyResourceColor
extends PropertyResource

static func for_prop(prop:Dictionary, prop_options:Dictionary, default_value:Variant, row_count:int) -> PropertyResourceColor:
    var resource:PropertyResourceColor = PropertyResourceColor.new()
    resource.property_name = prop['name']
    if row_count > 0:
        resource.data.resize(row_count)
        if resource.data[0] != default_value:
            for i:int in row_count:
                resource.data[i] = default_value
    return resource

@export_storage var data:PackedColorArray = [] 

func get_value(row_index:int) -> Color:
    return data[row_index]

func set_value(row_index:int, new_value:Color) -> void:
    data[row_index] = new_value

func delete_row(row_index:int) -> void:
    data.remove_at(row_index)

func delete_all_rows() -> void:
    data.clear()

func set_prop(prop:Dictionary, prop_options:Dictionary) -> String:
    if prop['type'] != TYPE_COLOR:
        return 'Expected property type Color but property had type %s' % _get_variant_type_string(prop['type'])

    property_name = prop['name']

    return ''
