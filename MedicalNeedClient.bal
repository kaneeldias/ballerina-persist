import ballerina/sql;

client class MedicalNeedClient {

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

    remote function readByKey(int key) returns MedicalNeed|error {
        anydata result = check self.persistClient.runReadByKeyQuery(key);
        return <MedicalNeed>result;
    }

    // TODO: filter query
    remote function read(map<anydata> filter) returns stream<MedicalNeed, error?>|error {
        stream<anydata, error?> result = check self.persistClient.runReadQuery(filter);
        return new stream<MedicalNeed, error?>(new MedicalNeedStream(result));
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

public class MedicalNeedStream {
    private stream<anydata, error?> anydataStream;

    public isolated function init(stream<anydata, error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|MedicalNeed value;|}|error? {
        var streamValue = self.anydataStream.next();
        if (streamValue is ()) {
            return streamValue;
        } else if (streamValue is error) {
            return streamValue;
        } else {
            record {|MedicalNeed value;|} nextRecord = {value: <MedicalNeed>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns error? {
        return self.anydataStream.close();
    }
}
