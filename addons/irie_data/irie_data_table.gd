@tool
class_name IrieDataTable
extends Resource

var table_name:String:
    get():
        return _table_name

@export_storage var _table_name:String
@export_storage var _property_resources:Dictionary = {}
@export_storage var _row_count:int = 0
@export_storage var _key_to_row_index_map:Dictionary = {}

var _schema_class:Variant
var _schema_options:Dictionary
var _key_property_name:StringName = ''
var _key_to_object_map:Dictionary = {}

func _set_schema_class(schema_class:Variant, schema_options:Dictionary):
    if schema_class is not GDScript:
        push_error('schema_class must be a GDScript defined class')
        return

    _schema_class = schema_class
    _schema_options = schema_options

    _update_property_resources()
    _verify_relations()

func _update_property_resources():
    var unused_property_resource_names:Array = _property_resources.keys()

    _key_property_name = ''

    for prop in _schema_class.get_script_property_list():
        var prop_usage:PropertyUsageFlags = prop['usage']
        if prop_usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
            var prop_name:String = prop['name']
            var prop_options:Dictionary = _schema_options.get(prop_name, {})
            var is_new:bool = _update_property_resource(prop)
            if not is_new:
                unused_property_resource_names.erase(prop_name)
            if prop_options.get('key', false):
                _key_property_name = prop_name

    for unused_property_resource_name in unused_property_resource_names:
        _property_resources.erase(unused_property_resource_name)

    if _key_property_name == '':
        push_error('No key property specified for table %s' % table_name)

func _update_property_resource(prop:Dictionary) -> bool:
    var prop_name:String = prop['name']
    var prop_options:Dictionary = _schema_options.get(prop_name, {})
    var resource = _property_resources.get(prop_name)
    if not resource:
        resource = _create_resource_for_property(prop, prop_options)
        _property_resources[prop_name] = resource
        return true
    else:
        var error_message:String = resource.set_prop(prop, prop_options)
        if error_message != '':
            push_error('Table %s property %s schema class mismatch: %s' % [table_name, prop_name, error_message])
        return false

func _create_resource_for_property(prop:Dictionary, prop_options:Dictionary) -> IrieDataProperty:
    var prop_name:String = prop['name']
    var prop_type:Variant.Type = prop['type']
    var prop_usage:PropertyUsageFlags = prop['usage']
    var default_value = _schema_class.get_property_default_value(prop_name)
    
    var resource:IrieDataProperty = null
    match prop_type:
        TYPE_BOOL:
            resource = IrieDataPropertyBool.for_prop(prop, prop_options, default_value, _row_count)
        TYPE_COLOR:
            resource = IrieDataPropertyColor.for_prop(prop, prop_options, default_value, _row_count)
        TYPE_FLOAT:
            resource = IrieDataPropertyFloat.for_prop(prop, prop_options, default_value, _row_count)
        TYPE_STRING when prop_options.get('auto', false):
            resource = IrieDataPropertyAutoKey.for_prop(prop, prop_options, default_value, _row_count)
        TYPE_STRING:
            resource = IrieDataPropertyString.for_prop(prop, prop_options, default_value, _row_count)
        TYPE_VECTOR3:
            resource = IrieDataPropertyVector3.for_prop(prop, prop_options, default_value, _row_count)
        TYPE_INT when prop_usage & PROPERTY_USAGE_CLASS_IS_ENUM:
            resource = IrieDataPropertyEnum.for_prop(prop, prop_options, default_value, _row_count)
        TYPE_OBJECT:
            resource = IrieDataPropertyForeignKey.for_prop(prop, prop_options, default_value, _row_count)

    if resource == null:
            push_error('Table %s schema class unsupported property: %s' % [table_name, prop])

    return resource

func _verify_relations():
    for prop_name in _schema_options:
        var prop_options = _schema_options[prop_name]
        if prop_options.has('relation'):
            var resource = _property_resources.get(prop_name)
            if not resource or not (resource is IrieDataPropertyForeignKey):
                push_error('Table %s property %s has relation but is not an object type' % [table_name, prop_name])

func get_row_count() -> int:
    return _row_count

func get_all_rows() -> Array[Object]:
    var result:Array[Object] = []
    result.resize(_row_count)
    var dst_index:int = 0
    for key in _key_to_row_index_map.keys():
        var row_object:Object = get_row(key)
        result[dst_index] = row_object
        dst_index += 1
    return result

func get_row(key:Variant) -> Object:
    var row_object:Object = _key_to_object_map.get(key, null)
    if row_object == null:
        var row_index:int = _key_to_row_index_map.get(key, -1)
        if row_index == -1:
            push_error('There is no row with key %s in table %s' % [key, _table_name])
            return null
        row_object = _schema_class.new()
        for resource:IrieDataProperty in _property_resources.values():
            row_object.set(resource.property_name, resource.get_value(row_index))
    return row_object

func delete_all_rows():
    _row_count = 0
    _key_to_row_index_map.clear()
    _key_to_object_map.clear()
    for resource:IrieDataProperty in _property_resources.values():
        resource.delete_all_rows()

func delete_row(key:Variant) -> bool:
    var row_index:int = _key_to_row_index_map.get(key, -1)
    if row_index == -1: 
        return false
    else:
        # remove key for deleted row from maps
        _key_to_row_index_map.erase(key)
        _key_to_object_map.erase(key)

        # update row index map for indexes above the one deleted
        for other_key in _key_to_row_index_map.keys():
            var other_row_index = _key_to_row_index_map[other_key]
            if other_row_index > row_index:
                _key_to_row_index_map[other_key] = other_row_index - 1

        # remove deleted row from all property resources
        for resource:IrieDataProperty in _property_resources.values():
            resource.delete_row(row_index)

        # one fewer rows now
        _row_count -= 1

        return true

func add_row(row_object:Object, save_related:bool = false) -> bool:
    var key_resource = _property_resources[_key_property_name]
    var key:Variant
    
    # If this is an auto-key, generate a new unique key
    if key_resource is IrieDataPropertyAutoKey:
        key = key_resource.generate_key()
        row_object.set(_key_property_name, key)
    else:
        key = row_object.get(_key_property_name)
        
    if _key_to_row_index_map.has(key):
        push_error('An row with key %s already exists in table %s' % [key, _table_name])
        return false
    else:
        # new rows are appended
        var row_index:int = _row_count

        # add key for added row to maps 
        _key_to_row_index_map[key] = row_index
        _key_to_object_map[key] = row_object

        # set value in property resource for added row
        for resource:IrieDataProperty in _property_resources.values():
            var value = row_object.get(resource.property_name)
            if save_related && resource is IrieDataPropertyForeignKey && value:
                resource.related_table.add_or_update_row(value, save_related)
            resource.set_value(row_index, value)

        # one more row now
        _row_count += 1

        return true

func update_row(row_object:Object, save_related:bool = false) -> bool:
    var key:Variant = row_object.get(_key_property_name)
    var row_index:int = _key_to_row_index_map.get(key, -1)
    if row_index == -1:
        push_error('No row with key %s exists in table %s' % [key, _table_name])
        return false
    else:
        # set value in property resource for updated row
        for resource:IrieDataProperty in _property_resources.values():
            var value = row_object.get(resource.property_name)
            if save_related && resource is IrieDataPropertyForeignKey && value:
                resource.related_table.add_or_update_row(value, save_related)
            resource.set_value(row_index, value)

        return true

func add_or_update_row(row_object:Object, save_related:bool = false) -> bool:
    if has_row(row_object.get(_key_property_name)):
        update_row(row_object, save_related)
        return false
    else:
        add_row(row_object, save_related)
        return true

func has_row(key:Variant) -> bool:
    return _key_to_row_index_map.has(key)
