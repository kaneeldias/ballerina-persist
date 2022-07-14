import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;
import ballerina/io;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable string DATABASE = ?;
configurable int PORT = ?;

public client class MedicalNeedClient {

    public final mysql:Client dbClient = check new(host = HOST, user = USER, password = PASSWORD, database = DATABASE, port = PORT);    

    public function init() returns error? {}

    remote function create(MedicalNeed value) returns int|error? {
        sql:ExecutionResult result = check self.dbClient->execute(`
            INSERT INTO MedicalNeeds (needId, itemId, beneficiaryId, period, urgency, quantity)
            VALUES (${value.needId}, ${value.itemId}, ${value.beneficiaryId}, ${value.period}, ${value.urgency}, ${value.quantity})
        `);
        if result.lastInsertId is () {
            return value.needId;
        }
        return <int>result.lastInsertId;
    }

    remote function readByKey(int key) returns MedicalNeed|error {
        return check self.dbClient->queryRow(`SELECT * FROM MedicalNeeds WHERE needId = ${key}`);
    }

    // TODO: filter query
    remote function read(map<anydata> filter) returns stream<MedicalNeed, error?>|error {
        sql:ParameterizedQuery query = sql:queryConcat(`SELECT * FROM MedicalNeeds WHERE`, check self.getWhereClauses(filter));
        io:println(query);
        stream<MedicalNeed, error?> resultStream = self.dbClient->query(query);
        return resultStream;
    }

    // TODO: filter query
    remote function update(record {} 'object, map<anydata> filter) returns error? {
        sql:ParameterizedQuery query = sql:queryConcat(`UPDATE MedicalNeeds SET`, check self.getSetClauses('object), ` WHERE`, check self.getWhereClauses(filter));
        io:println(query);
        _ = check self.dbClient->execute(query);
    }

    // TODO: filter query
    remote function delete(map<anydata> filter) returns error? {
        sql:ParameterizedQuery query = sql:queryConcat(`DELETE FROM MedicalNeeds WHERE`, check self.getWhereClauses(filter));
        io:println(query);
        _ = check self.dbClient->execute(query);
    }


    function getFieldParamQuery(string fieldName) returns sql:ParameterizedQuery|error {
        match fieldName {
            "itemId" => {
                return `itemId`;
            }
            "beneficiaryId" => {
                return `beneficiaryId`;
            }
            "period" => {
                return `period`;
            }
            "urgency" => {
                return `urgency`;
            }
            "quantity" => {
                return `quantity`;
            }
            _ => {
                return error("Field " + fieldName + " does not exist");
            }
        }
    }

    function getWhereClauses(map<anydata> filter) returns sql:ParameterizedQuery|error {
        sql:ParameterizedQuery query = ` `;
        boolean andFlag = false;
        foreach [string, anydata] [fieldName, value] in filter.entries() {
            sql:ParameterizedQuery appendedQuery;
            appendedQuery = sql:queryConcat(check self.getFieldParamQuery(fieldName),` = ${<sql:Value>value}`);

            if andFlag {
                appendedQuery = sql:queryConcat(` AND `, appendedQuery);
            } else {
                andFlag = true;
            }
            query = sql:queryConcat(query, appendedQuery);
        }
        return query;
    }

    function getSetClauses(record {} 'object) returns sql:ParameterizedQuery|error {
        boolean commaFlag = false;
        sql:ParameterizedQuery query = ` `;

        foreach [string, anydata] [fieldName, value] in 'object.entries() {
            sql:ParameterizedQuery appendedQuery = sql:queryConcat(check self.getFieldParamQuery(fieldName),` = ${<sql:Value>value}`);
            if commaFlag {
                appendedQuery = sql:queryConcat(`, `, appendedQuery);
            } else {
                commaFlag = true;
            }
            query = sql:queryConcat(query, appendedQuery);
        }
        return query;
    }

}