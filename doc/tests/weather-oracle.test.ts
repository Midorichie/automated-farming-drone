import { describe, expect, test } from "vitest";
import { Client, Provider, Receipt, Result } from "@blockstack/clarity";

describe("weather-oracle contract test suite", () => {
  let client: Client;
  let provider: Provider;

  beforeEach(async () => {
    provider = await Provider.makeProvider();
    client = new Client("SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB.weather-oracle", "weather-oracle", provider);
  });

  afterEach(async () => {
    await provider.close();
  });

  test("should return default weather condition when not set", async () => {
    const result = await client.executeContract(
      "get-weather-conditions",
      ["u100", "u100"]
    );
    expect(result.success).toBe(true);
    expect(result.result).toBe("sunny");
  });

  test("should set and get weather conditions", async () => {
    // Set weather condition
    const setResult = await client.executeContract(
      "set-weather-conditions",
      ["u100", "u100", "rainy"]
    );
    expect(setResult.success).toBe(true);

    // Get and verify weather condition
    const getResult = await client.executeContract(
      "get-weather-conditions",
      ["u100", "u100"]
    );
    expect(getResult.success).toBe(true);
    expect(getResult.result).toBe("rainy");
  });
});
