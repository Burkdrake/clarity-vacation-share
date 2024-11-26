import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Can create new vacation package as contract owner",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('vacation-booking', 'create-package', [
                types.ascii("Beach Resort"),
                types.ascii("Hawaii"),
                types.uint(10),
                types.uint(1000000)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk().expectUint(1);
    }
});

Clarinet.test({
    name: "Can book shares in a vacation package",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('vacation-booking', 'create-package', [
                types.ascii("Beach Resort"),
                types.ascii("Hawaii"),
                types.uint(10),
                types.uint(1000000)
            ], deployer.address),
            
            Tx.contractCall('vacation-booking', 'book-shares', [
                types.uint(1),
                types.uint(2)
            ], wallet1.address)
        ]);
        
        block.receipts[0].result.expectOk();
        block.receipts[1].result.expectOk();
        
        let getShares = chain.callReadOnlyFn(
            'vacation-booking',
            'get-available-shares',
            [types.uint(1)],
            wallet1.address
        );
        
        getShares.result.expectUint(8);
    }
});
