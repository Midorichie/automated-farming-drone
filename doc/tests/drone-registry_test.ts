import { describe, expect, test } from "vitest";
import { Client, Provider, Receipt, Result } from "@blockstack/clarity";

describe("drone-registry contract test suite", () => {
  let client: Client;
  let provider: Provider;

  beforeEach(async () => {
    provider = await Provider.makeProvider();
    client = new Client("SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB.drone-registry", "drone-registry", provider);
  });

  afterEach(async () => {
    await provider.close();
  });

  test("should register a new drone", async () => {
    // Add drone type certification first
    const certifyResult = await client.executeContract(
      "certify-drone-type",
      [
        "type:delivery",
        "u500", // max payload
        "u1000", // battery capacity
        "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM", // certification authority
        "u100000" // certification expiry
      ]
    );
    expect(certifyResult.success).toBe(true);

    const result = await client.executeContract(
      "register-drone",
      ["u1", "type:delivery"]
    );
    expect(result.success).toBe(true);

    // Check drone status
    const statusResult = await client.executeContract("get-drone-status", ["u1"]);
    expect(statusResult.success).toBe(true);
    expect(statusResult.result).toBe("active");
  });

  test("should set drone to maintenance mode", async () => {
    // First register a drone
    await client.executeContract(
      "register-drone",
      ["u1", "type:delivery"]
    );

    const result = await client.executeContract(
      "set-drone-maintenance",
      ["u1"]
    );
    expect(result.success).toBe(true);

    // Verify maintenance status
    const statusResult = await client.executeContract("get-drone-status", ["u1"]);
    expect(statusResult.success).toBe(true);
    expect(statusResult.result).toBe("maintenance");
  });
});
