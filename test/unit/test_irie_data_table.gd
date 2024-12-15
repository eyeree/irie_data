extends GutTest

# Test schema classes
class TestSchema:
    extends Resource
    var id: String
    var name: String
    var age: int
    var is_active: bool

class RelatedSchema:
    extends Resource
    var id: String
    var ref: Resource
    var value: String

func test_add_row():
    var table = IrieDataTable.new()
    table._table_name = "test"
    table._set_schema_class(TestSchema, {
        "id": { "key": true, "auto": true },
        "name": {},
        "age": {},
        "is_active": {}
    })
    
    var test_obj = TestSchema.new()
    test_obj.name = "Test"
    test_obj.age = 25
    test_obj.is_active = true
    
    assert_true(table.add_row(test_obj), "Should successfully add row")
    assert_eq(table.get_row_count(), 1, "Should increment row count")
    assert_true(test_obj.id != null, "Should set auto-generated key")

func test_get_row():
    var table = IrieDataTable.new()
    table._table_name = "test"
    table._set_schema_class(TestSchema, {
        "id": { "key": true },
        "name": {},
        "age": {},
        "is_active": {}
    })
    
    var test_obj = TestSchema.new()
    test_obj.id = "test1"
    test_obj.name = "Test"
    test_obj.age = 25
    test_obj.is_active = true
    
    table.add_row(test_obj)
    
    var retrieved = table.get_row("test1")
    assert_not_null(retrieved, "Should retrieve row")
    assert_eq(retrieved.id, "test1", "Should have correct id")
    assert_eq(retrieved.name, "Test", "Should have correct name")
    assert_eq(retrieved.age, 25, "Should have correct age")
    assert_eq(retrieved.is_active, true, "Should have correct is_active")

func test_update_row():
    var table = IrieDataTable.new()
    table._table_name = "test"
    table._set_schema_class(TestSchema, {
        "id": { "key": true },
        "name": {},
        "age": {},
        "is_active": {}
    })
    
    var test_obj = TestSchema.new()
    test_obj.id = "test1"
    test_obj.name = "Test"
    test_obj.age = 25
    test_obj.is_active = true
    
    table.add_row(test_obj)
    
    test_obj.name = "Updated"
    test_obj.age = 30
    assert_true(table.update_row(test_obj), "Should successfully update row")
    
    var updated = table.get_row("test1")
    assert_eq(updated.name, "Updated", "Should have updated name")
    assert_eq(updated.age, 30, "Should have updated age")

func test_delete_row():
    var table = IrieDataTable.new()
    table._table_name = "test"
    table._set_schema_class(TestSchema, {
        "id": { "key": true },
        "name": {},
        "age": {},
        "is_active": {}
    })
    
    var test_obj = TestSchema.new()
    test_obj.id = "test1"
    test_obj.name = "Test"
    test_obj.age = 25
    test_obj.is_active = true
    
    table.add_row(test_obj)
    assert_true(table.delete_row("test1"), "Should successfully delete row")
    assert_eq(table.get_row_count(), 0, "Should decrement row count")
    assert_false(table.has_row("test1"), "Should not have deleted row")

func test_get_all_rows():
    var table = IrieDataTable.new()
    table._table_name = "test"
    table._set_schema_class(TestSchema, {
        "id": { "key": true },
        "name": {},
        "age": {},
        "is_active": {}
    })
    
    var obj1 = TestSchema.new()
    obj1.id = "test1"
    obj1.name = "Test 1"
    
    var obj2 = TestSchema.new()
    obj2.id = "test2"
    obj2.name = "Test 2"
    
    table.add_row(obj1)
    table.add_row(obj2)
    
    var all_rows = table.get_all_rows()
    assert_eq(all_rows.size(), 2, "Should return all rows")
    # Check if rows exist by id
    var has_test1 = false
    var has_test2 = false
    for row in all_rows:
        if row.id == "test1":
            has_test1 = true
        elif row.id == "test2":
            has_test2 = true
    assert_true(has_test1, "Should contain first row")
    assert_true(has_test2, "Should contain second row")

func test_relations():
    var main_table = IrieDataTable.new()
    main_table._table_name = "main"
    main_table._set_schema_class(TestSchema, {
        "id": { "key": true },
        "name": {},
        "age": {},
        "is_active": {}
    })
    
    var related_table = IrieDataTable.new()
    related_table._table_name = "related"
    related_table._set_schema_class(RelatedSchema, {
        "id": { "key": true },
        "ref": { "relation": main_table },
        "value": {}
    })
    
    # Add main object
    var main_obj = TestSchema.new()
    main_obj.id = "main1"
    main_obj.name = "Main"
    main_table.add_row(main_obj)
    
    # Add related object
    var related_obj = RelatedSchema.new()
    related_obj.id = "rel1"
    related_obj.ref = main_obj
    related_obj.value = "Related Value"
    
    assert_true(related_table.add_row(related_obj), "Should add related row")
    
    var retrieved = related_table.get_row("rel1")
    assert_not_null(retrieved.ref, "Should have related object")
    assert_eq(retrieved.ref.id, "main1", "Should have correct related id")

func test_delete_all_rows():
    var table = IrieDataTable.new()
    table._table_name = "test"
    table._set_schema_class(TestSchema, {
        "id": { "key": true },
        "name": {},
        "age": {},
        "is_active": {}
    })
    
    var obj1 = TestSchema.new()
    obj1.id = "test1"
    var obj2 = TestSchema.new()
    obj2.id = "test2"
    
    table.add_row(obj1)
    table.add_row(obj2)
    
    table.delete_all_rows()
    assert_eq(table.get_row_count(), 0, "Should have no rows")
    assert_false(table.has_row("test1"), "Should not have first row")
    assert_false(table.has_row("test2"), "Should not have second row")

func test_add_or_update_row():
    var table = IrieDataTable.new()
    table._table_name = "test"
    table._set_schema_class(TestSchema, {
        "id": { "key": true },
        "name": {},
        "age": {},
        "is_active": {}
    })
    
    var test_obj = TestSchema.new()
    test_obj.id = "test1"
    test_obj.name = "Test"
    
    # Test add
    assert_true(table.add_or_update_row(test_obj), "Should add new row")
    assert_eq(table.get_row_count(), 1, "Should have one row")
    
    # Test update
    test_obj.name = "Updated"
    assert_false(table.add_or_update_row(test_obj), "Should update existing row")
    assert_eq(table.get_row_count(), 1, "Should still have one row")
    
    var updated = table.get_row("test1")
    assert_eq(updated.name, "Updated", "Should have updated name")
