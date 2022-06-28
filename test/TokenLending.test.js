const BToken = artifacts.require("BToken");
const StableCoin = artifacts.require("StableCoin"); // A mock of USDT
const TokenLending = artifacts.require("TokenLending");

require("chai").use(require("chai-as-promised")).should();

contract("TokenLending", (accounts) => {
  //write test inside here....

  let tokenLending, stableCoin, bMUsdt;

  const createBMusdtToken = async () => {
    let bMUsdtExist = await tokenLending.existingBTokens("bMUsdt");

    if (!bMUsdtExist) {
      await tokenLending.addBToken(stableCoin.address, "bMUsdt", "bMUsdt", 18);
    }

    bMUsdt = await BToken.at(await tokenLending.bTokens("bMUsdt"));
  };

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

  describe("Supply bMUsdt", async () => {
    it("Mint should work", async () => {
      await createBMusdtToken();
      await stableCoin.approve(bMUsdt.address, 10000);
      await tokenLending.mint("bMUsdt", 10);

      let bMUsdtBalanceOfMUsdt = (
        await stableCoin.balanceOf(bMUsdt.address)
      ).toNumber();
      let accountBalanceOfMUsdt = (
        await stableCoin.balanceOf(accounts[0])
      ).toNumber();
      let accountBalanceOfBMUsdt = (
        await bMUsdt.balanceOf(accounts[0])
      ).toNumber();

      assert.equal(10, bMUsdtBalanceOfMUsdt);
      assert.equal(10, accountBalanceOfBMUsdt);

      assert.equal(1000000000 - 10, accountBalanceOfMUsdt);
    });

    it("Redeem should work", async () => {
      await createBMusdtToken();
      await stableCoin.approve(bMUsdt.address, 10000);
      // There is already 10 mint because of before test
      await tokenLending.redeem("bMUsdt", 5);

      let bMUsdtBalanceOfMUsdt = (
        await stableCoin.balanceOf(bMUsdt.address)
      ).toNumber();
      let accountBalanceOfMUsdt = (
        await stableCoin.balanceOf(accounts[0])
      ).toNumber();
      let accountBalanceOfBMUsdt = (
        await bMUsdt.balanceOf(accounts[0])
      ).toNumber();

      assert.equal(5, bMUsdtBalanceOfMUsdt);
      assert.equal(5, accountBalanceOfBMUsdt);

      assert.equal(1000000000 - 5, accountBalanceOfMUsdt);
    });
  });
});
