import ballerina/io;

public function main() returns error? {
    // MedicalNeedClient mnClient = check new();
    // int idx = 23;
    // int? id = check mnClient->create({
    //     needId: idx,
    //     itemId: 1,
    //     beneficiaryId: 1,
    //     period: {year: 2022, month: 10, day: 10, hour: 0, minute: 0},
    //     urgency: "URGENT",
    //     quantity: 5
    // });
    // io:println(id);

    // record {} need = check mnClient->readByKey(idx);
    // io:println(need);

    // stream<record {}, error?> medicalNeedStream = check mnClient->read({itemId: 1, urgency: "URGENT"});
    // _ = check from record {} x in medicalNeedStream
    //     do {
    //         io:println(x);
    //     };

    // medicalNeedStream = check mnClient->read(`itemId = ${1} AND urgency = ${"URGENT"}`);
    // _ = check from record {} x in medicalNeedStream
    //     do {
    //         io:println(x);
    //     };

    // check mnClient->update({"beneficiaryId": 2, "quantity": 10}, {itemId: 1, urgency: "URGENT"});
    // medicalNeedStream = check mnClient->read({itemId: 1, urgency: "URGENT"});
    // _ = check from record {} x in medicalNeedStream
    //     do {
    //         io:println(x);
    //     };

    // check mnClient->delete({itemId: 1, urgency: "URGENT"});
    // medicalNeedStream = check mnClient->read({itemId: 1, urgency: "URGENT"});
    // _ = check from record {} x in medicalNeedStream
    //     do {
    //         io:println(x);
    //     };



    // MedicalItemClient miClient = check new();
    // id = check miClient->create({
    //     itemId: idx,
    //     name: "item1",
    //     'type: "liquid",
    //     unit: "ml"
    // });
    // io:println(id);

    // record {} item = check miClient->readByKey(idx);
    // io:println(item);

    // stream<record {}, error?> medicalItemStream = check miClient->read({'type: "liquid", unit: "ml"});
    // _ = check from record {} x in medicalItemStream
    //     do {
    //         io:println(x);
    //     };

    // check miClient->update({"name": "item2"}, {'type: "liquid", unit: "ml"});
    // medicalItemStream = check miClient->read({'type: "liquid", unit: "ml"});
    // _ = check from record {} x in medicalItemStream
    //     do {
    //         io:println(x);
    //     };

    // check miClient->delete({'type: "liquid", unit: "ml"});
    // medicalItemStream = check miClient->read({'type: "liquid", unit: "ml"});
    // _ = check from record {} x in medicalItemStream
    //     do {
    //         io:println(x);
    //     };

    MedicalNeed2Client mn2Client = check new();
    int? id = check mn2Client->create({
        itemId: 1,
        beneficiaryId: 1,
        period: {year: 2022, month: 10, day: 10, hour: 1, minute: 2, second: 3},
        urgency: "URGENT",
        quantity: 5
    });
    io:println(id);

    stream<record {}, error?> medicalNeedStream = check mn2Client->read({itemId: 1, urgency: "URGENT"});
    _ = check from record {} x in medicalNeedStream
        do {
            io:println(x);
        };
}
