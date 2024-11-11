@tool
class_name IrieDataPropertyForeignKey
extends IrieDataProperty

static func for_prop(prop:Dictionary, prop_options:Dictionary, default_value:Variant, row_count:int) -> IrieDataPropertyForeignKey:
    var related_table = prop_options.get('relation')
    if not related_table:
        push_error('Object property %s missing relation in schema options' % [prop['name']])
        return null

    var resource:IrieDataPropertyForeignKey = IrieDataPropertyForeignKey.new()
    resource.property_name = prop['name']
    resource.related_table = related_table

    if row_count > 0:
        resource.data.resize(row_count)
        if resource.data[0] != default_value:
            for i:int in row_count:
                resource.data[i] = default_value

    return resource

@export_storage var data:PackedStringArray = [] # Store foreign keys as strings
var related_table = null # Type: IrieDataTable, but referenced by variable to avoid circular dependency

func get_value(row_index:int) -> Object:
    var key = data[row_index]
    if related_table && key:
        return related_table.get_row(key)
    return null

func set_value(row_index:int, new_value:Object) -> void:
    if new_value:
        data[row_index] = str(new_value.get(related_table._key_property_name))
    else:
        data[row_index] = ""

func delete_row(row_index:int) -> void:
    data.remove_at(row_index)

func delete_all_rows() -> void:
    data.clear()

func set_prop(prop:Dictionary, prop_options:Dictionary) -> String:
    if prop['type'] != TYPE_OBJECT:
        return 'Expected property type Object but property had type %s.' % _get_variant_type_string(prop['type'])

    property_name = prop['name']

    related_table = prop_options.get('relation')
    if not related_table:
        return 'No relation was specified for an Object typed property.'

    return ''
