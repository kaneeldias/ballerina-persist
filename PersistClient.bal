import ballerina/sql;
import ballerinax/mysql;
import ballerina/io;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable string DATABASE = ?;
configurable int PORT = ?;

public client class PersistClient {

    private final mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, database = DATABASE, port = PORT);
    private sql:ParameterizedQuery tableName;
    private map<[string, sql:ParameterizedQuery]> fieldMap;
    private string[] keyFields;

    public function init(sql:ParameterizedQuery tableName, map<[string, sql:ParameterizedQuery]> fieldMap, string[] keyFields) returns error? {
        self.tableName = tableName;
        self.fieldMap = fieldMap;
        self.keyFields = keyFields;
    }

    function runInsertQuery(record {} 'object) returns sql:ExecutionResult|error {
        sql:ParameterizedQuery query = sql:queryConcat(
            `INSERT INTO `, self.tableName, ` (`,
            self.getColumnNames(), `) `,
            `VALUES `, self.getInsertQueryParams('object)
        );
        return check self.dbClient->execute(query);
    }

    function runReadByKeyQuery(anydata key) returns record {}|error {
        sql:ParameterizedQuery query = sql:queryConcat(
            `SELECT `, self.getColumnNames(), ` FROM `, self.tableName, ` WHERE `, check self.getGetKeyWhereClauses(key)
        );
        return check self.dbClient->queryRow(query);
    }

    function runReadQuery(map<anydata> filter) returns stream<record {}, error?>|error {
        sql:ParameterizedQuery query = sql:queryConcat(
            `SELECT * FROM `, self.tableName, ` WHERE`, check self.getWhereClauses(filter)
        );
        io:println(query);
        stream<record {}, error?> resultStream = self.dbClient->query(query);
        return resultStream;

    }

    function runUpdateQuery(record {} 'object, map<anydata> filter) returns error? {
        sql:ParameterizedQuery query = sql:queryConcat(
            `UPDATE `, self.tableName, ` SET`, check self.getSetClauses('object), ` WHERE`, check self.getWhereClauses(filter));
        io:println(query);
        _ = check self.dbClient->execute(query);
    }

    function runDeleteQuery(map<anydata> filter) returns error? {
        sql:ParameterizedQuery query = sql:queryConcat(
            `DELETE FROM `, self.tableName, ` WHERE`, check self.getWhereClauses(filter)
        );
        io:println(query);
        _ = check self.dbClient->execute(query);
    }


    private function getInsertQueryParams(record {} 'object) returns sql:ParameterizedQuery {
        sql:ParameterizedQuery params = `(`;
        boolean commaFlag = false;
        foreach [string, anydata] [_, value] in 'object.entries() {
            if !commaFlag {
                params = sql:queryConcat(params, `${<sql:Value>value}`);
                commaFlag = true;
            } else {
                params = sql:queryConcat(params, `, ${<sql:Value>value}`);
            }
        }
        params = sql:queryConcat(params, `)`);
        return params;
    }

    private function getColumnNames() returns sql:ParameterizedQuery {
        sql:ParameterizedQuery params = ` `;
        boolean commaFlag = false;
        foreach [string, [string, sql:ParameterizedQuery]] [_, [_, value]] in self.fieldMap.entries() {
            if !commaFlag {
                params = sql:queryConcat(params, value);
                commaFlag = true;
            } else {
                params = sql:queryConcat(params, `, `, value);
            }
        }
        return params;
    }

    // TODO: handle composite keys (record types)
    private function getGetKeyWhereClauses(anydata key) returns sql:ParameterizedQuery|error {
        map<anydata> filter = {};
        filter[self.keyFields[0]] = key;
        return check self.getWhereClauses(filter);
    }

    function getWhereClauses(map<anydata> filter) returns sql:ParameterizedQuery|error {
        sql:ParameterizedQuery query = ` `;
        boolean andFlag = false;
        foreach [string, anydata] [fieldName, value] in filter.entries() {
            sql:ParameterizedQuery appendedQuery;
            appendedQuery = sql:queryConcat(check self.getFieldParamQuery(fieldName), ` = ${<sql:Value>value}`);

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
            sql:ParameterizedQuery appendedQuery = sql:queryConcat(check self.getFieldParamQuery(fieldName), ` = ${<sql:Value>value}`);
            if commaFlag {
                appendedQuery = sql:queryConcat(`, `, appendedQuery);
            } else {
                commaFlag = true;
            }
            query = sql:queryConcat(query, appendedQuery);
        }
        return query;
    }


    function getFieldParamQuery(string fieldName) returns sql:ParameterizedQuery|error {
        return self.fieldMap.get(fieldName)[1];
    }


}