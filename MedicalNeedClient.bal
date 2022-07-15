import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;

client class MedicalNeedClient {

    private final mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, database = DATABASE, port = PORT);
    private final sql:ParameterizedQuery tableName = `MedicalNeeds`;
    private final map<[string, sql:ParameterizedQuery]> fieldMap = {
        needId: ["needId", `needId`],
        itemId: ["itemId", `itemId`],
        beneficiaryId: ["beneficiaryId", `beneficiaryId`],
        period: ["period", `period`],
        urgency: ["urgency", `urgency`],
        quantity: ["quantity", `quantity`]
    };
    private string[] keyFields = ["needId"];

    private PersistClient persistClient;

    public function init() returns error? {
        self.persistClient = check new(self.tableName, self.fieldMap, self.keyFields);
    }

    remote function create(MedicalNeed value) returns int|error? {
        sql:ExecutionResult result = check self.persistClient.runInsertQuery(value);

        if result.lastInsertId is () {
            return value.needId;
        }
        return <int>result.lastInsertId;
    }

    // TODO: change return type to `MedicalNeed`
    remote function readByKey(int key) returns record {}|error {
        return check self.persistClient.runReadByKeyQuery(key);
    }

    // TODO: filter query
    // TODO: change return type to `MedicalNeed`
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
