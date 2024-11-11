@tool
class_name PropertyResourceAutoKey
extends PropertyResourceString

static func for_prop(prop:Dictionary, prop_options:Dictionary, default_value:Variant, row_count:int) -> PropertyResourceAutoKey:
    var resource:PropertyResourceAutoKey = PropertyResourceAutoKey.new()
    resource.property_name = prop['name']
    resource.next_unique_id = 1
    if row_count > 0:
        resource.data.resize(row_count)
        if resource.data[0] != default_value:
            for i:int in row_count:
                resource.data[i] = default_value
    return resource

@export_storage var next_unique_id:int = 1

func generate_key() -> String:
    var key = str(next_unique_id)
    next_unique_id += 1
    return key
