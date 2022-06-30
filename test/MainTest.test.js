const { assert } = require("chai");

const BTokenImmutable = artifacts.require("BTokenImmutable");
const StableCoin = artifacts.require("StableCoin"); // A mock of USDT
const Comptroller = artifacts.require("Comptroller");

require("chai").use(require("chai-as-promised")).should();

contract("Init new Asset", (accounts) => {
  //write test inside here....

  let comptroller, stableCoin, bToken;

  before(async () => {
    //contract load
    comptroller = await Comptroller.new();
    //create a stable Coin
    stableCoin = await StableCoin.new("Mock USDT", "mUsdt", 18, 1000000000);
    //transfer some Liquidity to admin
    await stableCoin.adminTransfer(accounts[0], 100000);
  });

  // Test addBToken
  describe("Add BToken", async () => {
    it("Should create a BToken & add to comptroller List", async () => {
      bToken = await BTokenImmutable.new(
        stableCoin.address,
        comptroller.address,
        "bMUsdt",
        "bMUsdt",
        18,
        accounts[0]
      );
      assert.equal(true, await bToken.isBToken());
      //add BToken from new Method
      await comptroller._supportMarket(bToken.address);

      let allMarkets = await comptroller.getAllMarkets();
      console.log(allMarkets);

    });
  });
});

contract("Supply Asset", (accounts) => {
  //write test inside here....

  let comptroller, stableCoin, bToken;

  before(async () => {
    //contract load
    comptroller = await Comptroller.new();

    //create a stable Coin
    stableCoin = await StableCoin.new("Mock USDT", "mUsdt", 18, 1000000000);
    //transfer some Liquidity to admin
    await stableCoin.adminTransfer(accounts[0], 100000);

    //Create BToken
    bToken = await BTokenImmutable.new(
      stableCoin.address,
      comptroller.address,
      "bMUsdt",
      "bMUsdt",
      18,
      accounts[0]
    );

    //Add BToken to Market Comptroller
    await comptroller._supportMarket(bToken.address);
  });

  // Test addBToken
  describe("Add Supply Stable To Get BToken", async () => {
    it("Should Mint and receive BToken", async () => {
      assert.equal(true, await bToken.isBToken());

      await stableCoin.approve(bToken.address, 10000);

      await bToken.mint(10);

      //load your amount of stable
      let accountBalanceOfStable = (
        await stableCoin.balanceOf(accounts[0])
      ).toNumber();

      //load BToken amount of stable
      let bTokenBalanceOfStable = (
        await stableCoin.balanceOf(bToken.address)
      ).toNumber();

      //load your amount of Btoken
      let accountBalanceOfBToken = (
        await bToken.balanceOf(accounts[0])
      ).toNumber();

      assert.equal(100000 - 10, accountBalanceOfStable);
      assert.equal(10, bTokenBalanceOfStable);
      assert.equal(10, accountBalanceOfBToken);
    });
  });
});

contract("Redeem Asset", (accounts) => {

  let comptroller, stableCoin, bToken;

  before(async () => {
    //contract load
    comptroller = await Comptroller.new();
    //create a stable Coin
    stableCoin = await StableCoin.new("Mock USDT", "mUsdt", 18, 1000000000);
    //transfer some Liquidity to admin
    await stableCoin.adminTransfer(accounts[0], 100000);
    //Create BToken
    bToken = await BTokenImmutable.new(
      stableCoin.address,
      comptroller.address,
      "bMUsdt",
      "bMUsdt",
      18,
      accounts[0]
    );
    //Add BToken to Market Comptroller
    await comptroller._supportMarket(bToken.address);
    //approve transaction
    await stableCoin.approve(bToken.address, 10);
    //mint 10
    await bToken.mint(10);
  });

  // Test redeem
  describe("Swap Btoken To Get Stable", async () => {
    it("you have btoken and you want stable", async () => {
      assert.equal(true, await bToken.isBToken());
      //approve transaction
      await stableCoin.approve(bToken.address, 10);
      //mint 10
      await bToken.redeem(10);

      //load your amount of stable
      let accountBalanceOfStable = (
        await stableCoin.balanceOf(accounts[0])
      ).toNumber();
      //load your amount of Btoken
      let accountBalanceOfBToken = (
        await bToken.balanceOf(accounts[0])
      ).toNumber();

      console.log("Stable in account[0]:",accountBalanceOfStable)
      console.log("BToken in account[0]:",accountBalanceOfBToken)
      assert.equal(100000, accountBalanceOfStable);
      assert.equal(0, accountBalanceOfBToken);
    });
  });
});


