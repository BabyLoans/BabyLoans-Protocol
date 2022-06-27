const { assert } = require("chai");

const StableCoin = artifacts.require("StableCoin");

require("chai").use(require("chai-as-promised")).should();

function tokens(n) {
  return web3.utils.toWei(n, "ether");
}

contract("StableCoin", (accounts) => {
  //write test inside here....

  let stableCoin;

  before(async () => {
    //contract load
    stableCoin = await StableCoin.new("Mock USDT", "mUsdt", 18, 1000000000);
  });

  // Test balanceOf
  describe("Balance of me", async () => {
    it("has 1000000000 tokens", async () => {
      let balance = await stableCoin.balanceOf(accounts[0]);
      assert.equal(balance.toNumber(), 1000000000);
    });
  });

  // Test transfer
  describe("Transfer to", async () => {
    it("Should work", async () => {
      let initialBalance = await stableCoin.balanceOf(accounts[1]);
      let result = await stableCoin.transfer(accounts[1], 1);

      assert.equal(true, result.receipt.status);

      let finalBalance = await stableCoin.balanceOf(accounts[1]);
      assert.equal(initialBalance.toNumber() + 1, finalBalance.toNumber());
    });
  });

  describe("Transfer from", async () => {
    it("Should work", async () => {
      let initialBalance = await stableCoin.balanceOf(accounts[1]);
      let result = await debug(
        stableCoin.transferFrom(accounts[0], accounts[1], 1)
      );

      assert.equal(true, result.receipt.status);

      let finalBalance = await stableCoin.balanceOf(accounts[1]);
      assert.equal(initialBalance.toNumber() + 1, finalBalance.toNumber());
    });
  });
});
