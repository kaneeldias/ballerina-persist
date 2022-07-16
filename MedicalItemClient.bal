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

    remote function readByKey(int key) returns MedicalItem|error {
        anydata result = check self.persistClient.runReadByKeyQuery(key);
        return <MedicalItem>result;
    }

    // TODO: filter query
    remote function read(map<anydata> filter) returns stream<MedicalItem, error?>|error {
        stream<anydata, error?> result = check self.persistClient.runReadQuery(filter);
        return new stream<MedicalItem, error?>(new MedicalItemStream(result));
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

public class MedicalItemStream {
    private stream<anydata, error?> anydataStream;

    public isolated function init(stream<anydata, error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|MedicalItem value;|}|error? {
        var streamValue = self.anydataStream.next();
        if (streamValue is ()) {
            return streamValue;
        } else if (streamValue is error) {
            return streamValue;
        } else {
            record {|MedicalItem value;|} nextRecord = {value: <MedicalItem>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns error? {
        return self.anydataStream.close();
    }
}
