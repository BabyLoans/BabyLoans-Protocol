const StableCoin = artifacts.require("StableCoin");
const TokenLending = artifacts.require("TokenLending");

require("chai").use(require("chai-as-promised")).should();

contract("TokenLending", (accounts) => {
  //write test inside here....

  let tokenLending, stableCoin;

  before(async () => {
    //contract load
    tokenLending = await TokenLending.new();
    stableCoin = await StableCoin.new("Mock USDT", "mUsdt", 18, 1000000000);
  });

  // Test addBToken
  describe("Add BToken", async () => {
    it("Should create a BToken", async () => {
      let bMUsdtExist = await tokenLending.existingBTokens("bMUsdt");

      assert.equal(false, bMUsdtExist);

      await tokenLending.addBToken(stableCoin.address, "bMUsdt", "bMUsdt", 18);

      bMUsdtExist = await tokenLending.existingBTokens("bMUsdt");
      assert.equal(true, bMUsdtExist);
    });
  });

  describe("Mint bMusdt", async () => {
    it("Should work", async () => {
      let bMUsdtExist = await tokenLending.existingBTokens("bMUsdt");

      if (!bMUsdtExist) {
        await tokenLending.addBToken(
          stableCoin.address,
          "bMUsdt",
          "bMUsdt",
          18
        );
      }

      let trx = await tokenLending.mint("bMUsdt", 10);
      assert.equal(true, trx.receipt.status);
    });
  });
});
