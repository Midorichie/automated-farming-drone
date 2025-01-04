;; tests/drone-registry_test.ts
import {
    Chain,
    Account,
    Tx,
    types,
    assertEquals,
} from "../deps.ts";

Clarinet.test({
    name: "Ensure that drone registration works",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get("deployer")!;
        
        let block = chain.mineBlock([
            Tx.contractCall(
                "drone-registry",
                "register-drone",
                [types.uint(1)],
                deployer.address
            ),
        ]);
        
        assertEquals(block.receipts.length, 1);
        assertEquals(block.height, 2);
        block.receipts[0].result.expectOk().expectBool(true);
    },
});
