import ballerina/io;

public function main() returns error? {
    MedicalNeedClient mnClient = check new();
    int idx = 10;
    int? id = check mnClient->create({
        needId: idx,
        itemId: 1,
        beneficiaryId: 1,
        period: {year: 2022, month: 10, day: 10, hour: 0, minute: 0},
        urgency: "URGENT",
        quantity: 5
    });
    io:println(id);

    MedicalNeed need = check mnClient->readByKey(1);
    io:println(need);

    stream<MedicalNeed, error?> medicalNeedStream = check mnClient->read({itemId: 1, urgency: "URGENT"});
    _ = check from MedicalNeed x in medicalNeedStream
        do {
            io:println(x);
        };

    check mnClient->update({"beneficiaryId": 2, "quantity": 10}, {itemId: 1, urgency: "URGENT"});
    medicalNeedStream = check mnClient->read({itemId: 1, urgency: "URGENT"});
    _ = check from MedicalNeed x in medicalNeedStream
        do {
            io:println(x);
        };

    check mnClient->delete({itemId: 1, urgency: "URGENT"});
    medicalNeedStream = check mnClient->read({itemId: 1, urgency: "URGENT"});
    _ = check from MedicalNeed x in medicalNeedStream
        do {
            io:println(x);
        };
}
