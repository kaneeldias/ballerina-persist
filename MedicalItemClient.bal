import ballerina/sql;

client class MedicalItemClient {

    private final sql:ParameterizedQuery tableName = `MedicalItem`;
    private final map<[string, sql:ParameterizedQuery]> fieldMap = {
        itemId: ["itemId", `itemId`],
        name: ["name", `name`],
        'type: ["type", `type`],
        unit: ["unit", `unit`]
    };
    private string[] keyFields = ["itemId"];

    private PersistClient persistClient;

    public function init() returns error? {
        self.persistClient = check new(self.tableName, self.fieldMap, self.keyFields);
    }

    remote function create(MedicalItem value) returns int|error? {
        sql:ExecutionResult result = check self.persistClient.runInsertQuery(value);

        if result.lastInsertId is () {
            return value.itemId;
        }
        return <int>result.lastInsertId;
    }

    // TODO: change return type to `MedicalItem`
    remote function readByKey(int key) returns record {}|error {
        return check self.persistClient.runReadByKeyQuery(key);
    }

    // TODO: filter query
    // TODO: change return type to `MedicalItem`
    remote function read(map<anydata> filter) returns stream<record {}, error?>|error {
        return self.persistClient.runReadQuery(filter);
    }

    // TODO: filter query
    remote function update(record {} 'object, map<anydata> filter) returns error? {
        _ = check self.persistClient.runUpdateQuery('object, filter);
    }

    // TODO: filter query
    remote function delete(map<anydata> filter) returns error? {
        _ = check self.persistClient.runDeleteQuery(filter);
    }

}
