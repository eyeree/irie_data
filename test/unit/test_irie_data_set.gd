extends GutTest

# Test schema classes
class TestSchema:
    extends Resource
    var id: String
    var name: String
    var age: int
    var is_active: bool

class PostSchema:
    extends Resource
    var id: String
    var user: Resource  # This will reference a user
    var title: String

func test_table_key_returns_key_option():
    var target = IrieDataSet.new()
    var actual = target.table_key()
    assert_eq(actual, { 'key': true })

func test_table_auto_key_returns_auto_key_option():
    var target = IrieDataSet.new()
    var actual = target.table_auto_key()
    assert_eq(actual, { 'key': true, 'auto': true })

func test_table_relation_returns_relation_option():
    var target = IrieDataSet.new()
    var related_table = IrieDataTable.new()
    var actual = target.table_relation(related_table)
    assert_eq(actual, { 'relation': related_table })

func test_table_creates_new_table_if_not_exists():
    var target = IrieDataSet.new()
    var table = target.table("test_table", TestSchema)
    assert_not_null(table, "Table should be created")
    assert_eq(table.table_name, "test_table", "Table should have correct name")
    assert_true(table is IrieDataTable, "Table should be IrieDataTable instance")

func test_table_returns_existing_table_if_exists():
    var target = IrieDataSet.new()
    var table1 = target.table("test_table", TestSchema)
    var table2 = target.table("test_table", TestSchema)
    assert_eq(table1, table2, "Should return same table instance")

func test_table_sets_schema_class():
    var target = IrieDataSet.new()
    var options = {
        "id": target.table_auto_key(),
        "name": {},
        "age": {},
        "is_active": {}
    }
    var table = target.table("test_table", TestSchema, options)
    # Since _schema_class is private, we can verify it was set by checking if we can add a row
    var test_obj = TestSchema.new()
    test_obj.name = "Test"
    test_obj.age = 25
    test_obj.is_active = true
    assert_true(table.add_row(test_obj), "Should be able to add row with schema")

func test_table_stores_tables_in_dictionary():
    var target = IrieDataSet.new()
    var table1 = target.table("table1", TestSchema)
    var table2 = target.table("table2", TestSchema)
    assert_has(target.tables, "table1", "Should store first table")
    assert_has(target.tables, "table2", "Should store second table")
    assert_eq(target.tables["table1"], table1, "Should store correct table instance")
    assert_eq(target.tables["table2"], table2, "Should store correct table instance")

func test_table_with_relations():
    var target = IrieDataSet.new()
    
    # Create a users table with auto key
    var users_table = target.table("users", TestSchema, {
        "id": target.table_auto_key(),
        "name": {},
        "age": {},
        "is_active": {}
    })
    
    # Create a posts table that relates to users
    var posts_table = target.table("posts", PostSchema, {
        "id": target.table_auto_key(),
        "user": target.table_relation(users_table),
        "title": {}
    })
    
    assert_not_null(posts_table, "Posts table should be created")
    assert_eq(posts_table.table_name, "posts", "Posts table should have correct name")
