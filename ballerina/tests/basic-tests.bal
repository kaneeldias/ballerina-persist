import ballerina/test;
import ballerinax/mysql;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable string DATABASE = ?;
configurable int PORT = ?;

@test:BeforeSuite
function truncate() returns error? {
    mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, database = DATABASE, port = PORT);
    _ = check dbClient->execute(`TRUNCATE MedicalNeeds`);
    _ = check dbClient->execute(`TRUNCATE MedicalItems`);
    check dbClient.close();
}

@test:Config {
    groups: ["basic"]
}
function testCreate() returns error? {
    MedicalItemClient miClient = check new();
    MedicalItem item = {
        itemId: 1,
        name: "item name",
        'type: "item type",
        unit: "ml"
    };
    int? id = check miClient->create(item);
    check miClient.close();
    test:assertTrue(id is int);
}

@test:Config {
    groups: ["basic"]
}
function testCreateWithAutogeneratedKey() returns error? {
    MedicalNeedClient mnClient = check new();
    int? id = check mnClient->create({
        itemId: 1,
        beneficiaryId: 1,
        period: { year: 2022, month: 10, day: 10, hour: 1, minute: 2, second: 3 },
        urgency: "URGENT",
        quantity: 5
    });
    check mnClient.close();
    test:assertTrue(id is int);
}

@test:Config {
    groups: ["basic"],
    dependsOn: [testCreate]
}
function testReadByKey() returns error? {
    MedicalItemClient miClient = check new();
    MedicalItem item = check miClient->readByKey(1);
    test:assertEquals(item, {
        itemId: 1,
        name: "item name",
        'type: "item type",
        unit: "ml"        
    });
    check miClient.close();
}

@test:Config {
    groups: ["basic"],
    dependsOn: [testCreate]
}
function testReadByKeyNegative() returns error? {
    MedicalItemClient miClient = check new();
    MedicalItem|error item = miClient->readByKey(20);
    if item is InvalidKey {
        test:assertEquals(item.message(), "A record does not exist for 'MedicalItems' for key 20.");
    } else {
        test:assertFail("Error expected.");
    }
    check miClient.close();
}

@test:Config {
    groups: ["basic"],
    dependsOn: [testCreate]
}
function testRead() returns error? {
    MedicalItemClient miClient = check new();
    _ = check miClient->create({
        itemId: 2,
        name: "item2 name",
        'type: "type1",
        unit: "ml"
    });
    _ = check miClient->create({
        itemId: 3,
        name: "item2 name",
        'type: "type2",
        unit: "ml"
    });
    _ = check miClient->create({
        itemId: 4,
        name: "item2 name",
        'type: "type2",
        unit: "kg"
    });

    int count = 0;
    stream<MedicalItem, error?> itemStream = check miClient->read({ 'type: "type1" });
    _ = check from MedicalItem _ in itemStream
        do {
            count = count + 1;
        };
    test:assertEquals(count, 1);

    count = 0;
    itemStream = check miClient->read({ 'type: "type2" });
    _ = check from MedicalItem _ in itemStream
        do {
            count = count + 1;
        };
    check miClient.close();
    test:assertEquals(count, 2);
}

@test:Config {
    groups: ["basic"],
    dependsOn: [testCreate]
}
function testReadNegative() returns error? {
    MedicalItemClient miClient = check new();
    stream<MedicalItem, error?>|error itemStream = miClient->read({ typex: "type1" });
    if itemStream is FieldDoesNotExist {
        test:assertEquals(itemStream.message(), "Field 'typex' does not exist in entity 'MedicalItems'.");
    } else {
        test:assertFail("Error expected");
    }
    check miClient.close();
}

@test:Config {
    groups: ["basic"],
    dependsOn: [testRead]
}
function testUpdate() returns error? {
    MedicalItemClient miClient = check new();
    check miClient->update({ "unit": "kg" }, { 'type: "type2" });
    stream<MedicalItem, error?> itemStream = check miClient->read();
    int count = 0;
    _ = check from MedicalItem item in itemStream
        do {
            if item.'type is "type2" {
                test:assertEquals(item.unit, "kg");
                count = count + 1;
            } else {
                test:assertEquals(item.unit, "ml");
            }
        };
    test:assertEquals(count, 2);
    check miClient.close();
}

@test:Config {
    groups: ["basic"],
    dependsOn: [testRead]
}
function testUpdateNegative() returns error? {
    MedicalItemClient miClient = check new();
    error? result = miClient->update({ "units": "kg" }, { 'type: "type2" });
    if result is FieldDoesNotExist {
        test:assertEquals(result.message(), "Field 'units' does not exist in entity 'MedicalItems'.");
    } else {
        test:assertFail("Error expected.");
    }
    check miClient.close();
}

@test:Config {
    groups: ["basic"],
    dependsOn: [testUpdate]
}
function testDelete() returns error? {
    MedicalItemClient miClient = check new();
    check miClient->delete({ 'type: "type2" });
    stream<MedicalItem, error?> itemStream = check miClient->read();
    int count = 0;
    _ = check from MedicalItem _ in itemStream
        do {
            count = count + 1;
        };
    test:assertEquals(count, 2);
    check miClient.close();
}

@test:Config {
    groups: ["basic"],
    dependsOn: [testUpdate]
}
function testDeleteNegative() returns error? {
    MedicalItemClient miClient = check new();
    error? result = miClient->delete({ 'types: "type2" });
    if result is FieldDoesNotExist {
        test:assertEquals(result.message(), "Field 'types' does not exist in entity 'MedicalItems'.");
    } else {
        test:assertFail("Error expected.");
    }
    check miClient.close();
}
