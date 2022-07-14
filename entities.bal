import ballerina/time;

public type MedicalNeed record {|
  readonly int needId;
  int itemId; 
  int beneficiaryId; 
  time:Civil  period;
  string urgency;
  int quantity;
|};

public enum Urgency {
  NORMAL = "NORMAL",
  CRUCIAL = "CRUCIAL",
  URGENT = "URGENT"
}
