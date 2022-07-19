import ballerina/sql;
import ballerinax/mysql;
import ballerina/time;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable string DATABASE = ?;
configurable int PORT = ?;

client class MedicalNeedClient {

    private final string entityName = "MedicalNeed";
    private final sql:ParameterizedQuery tableName = `MedicalNeeds`;
    
    // TODO: Include SQL metadata (AUTO GENERATED etc.)
    private final map<FieldMetadata> fieldMetadata = {
        needId: { columnName: "needId", 'type: int },
        itemId: { columnName: "itemId", 'type: int },
        beneficiaryId: { columnName: "beneficiaryId", 'type: int },
        period: { columnName: "period", 'type: time:Civil },
        urgency: { columnName: "urgency", 'type: string },
        quantity: { columnName: "quantity", 'type: int }
    };
    private string[] keyFields = ["needId"];

    private SQLClient persistClient;

    public function init() returns error? {
        mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, database = DATABASE, port = PORT);
        self.persistClient = check new(self.entityName, self.tableName, self.fieldMetadata, self.keyFields, dbClient);
    }

    remote function create(MedicalNeed value) returns int|error? {
        sql:ExecutionResult result = check self.persistClient.runInsertQuery(value);

        //TODO: How can we handle returning composite keys
        if result.lastInsertId is () {
            return value.needId;
        }
        return <int>result.lastInsertId;
    }

    // TODO: change return type to `MedicalNeed`
    remote function readByKey(int key) returns record {}|error {
        return check self.persistClient.runReadByKeyQuery(key);
    }

    // TODO: change return type to `MedicalNeed`
    remote function read(map<anydata>|FilterQuery filter) returns stream<record {}, sql:Error?>|error {
        return self.persistClient.runReadQuery(filter);
    }

    remote function update(record {} 'object, map<anydata>|FilterQuery filter) returns error? {
        _ = check self.persistClient.runUpdateQuery('object, filter);
    }

    remote function delete(map<anydata>|FilterQuery filter) returns error? {
        _ = check self.persistClient.runDeleteQuery(filter);
    }

}
