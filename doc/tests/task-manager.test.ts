import { describe, expect, test } from "vitest";
import { Client, Provider, Receipt, Result } from "@blockstack/clarity";

describe("task-manager contract test suite", () => {
  let client: Client;
  let provider: Provider;

  beforeEach(async () => {
    provider = await Provider.makeProvider();
    client = new Client("SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB.task-manager", "task-manager", provider);
  });

  afterEach(async () => {
    await provider.close();
  });

  test("should assign a task with weather check", async () => {
    // First register a drone
    await client.executeContract(
      "drone-registry.register-drone",
      ["u1", "type:delivery"]
    );

    const result = await client.executeContract(
      "assign-task-with-weather",
      [
        "u1", // task id
        "u1", // drone id
        "spraying", // task type
        "u100", // x coordinate
        "u100", // y coordinate
        "u1", // priority
        "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.weather-oracle" // weather oracle contract
      ]
    );
    expect(result.success).toBe(true);

    // Check task status
    const statusResult = await client.executeContract("get-task-status", ["u1"]);
    expect(statusResult.success).toBe(true);
    expect(statusResult.result).toBe("pending");
  });

  test("should update task status", async () => {
    // First create a task
    await client.executeContract(
      "assign-task-with-weather",
      [
        "u1", // task id
        "u1", // drone id
        "spraying", // task type
        "u100", // x coordinate
        "u100", // y coordinate
        "u1", // priority
        "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.weather-oracle" // weather oracle contract
      ]
    );

    const result = await client.executeContract(
      "update-task-status",
      ["u1", "completed"]
    );
    expect(result.success).toBe(true);

    // Verify updated status
    const statusResult = await client.executeContract("get-task-status", ["u1"]);
    expect(statusResult.success).toBe(true);
    expect(statusResult.result).toBe("completed");
  });
});
