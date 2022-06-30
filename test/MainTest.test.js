const { assert } = require("chai");
const truffleAssert = require('truffle-assertions');

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
    stableCoin = await StableCoin.new("Mock USDT", "mUsdt", 18, web3.utils.toWei(1000000000000));
    //transfer some Liquidity to admin
    await stableCoin.adminTransfer(accounts[0], web3.utils.toWei(10000));
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
      //add BToken from new Mweb3od
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
    stableCoin = await StableCoin.new("Mock USDT", "mUsdt", 18, web3.utils.toWei(1000000000000));
    //transfer some Liquidity to admin
    await stableCoin.adminTransfer(accounts[0], web3.utils.toWei(10000));

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

      await stableCoin.approve(bToken.address,  web3.utils.toWei(10000));

      await bToken.mint(web3.utils.toWei(10));

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

      assert.equal(10000 - 10, web3.utils.fromWei(accountBalanceOfStable));
      assert.equal(10,  web3.utils.fromWei(bTokenBalanceOfStable));
      assert.equal(10, web3.utils.fromWei(accountBalanceOfBToken));
    });
  });
});

contract("Redeem Asset", (accounts) => {

  let comptroller, stableCoin, bToken;

  before(async () => {
    //contract load
    comptroller = await Comptroller.new();
    //create a stable Coin
    stableCoin = await StableCoin.new("Mock USDT", "mUsdt", 18, web3.utils.toWei(1000000000000));
    //transfer some Liquidity to admin
    await stableCoin.adminTransfer(accounts[0], web3.utils.toWei(100000));
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
    await stableCoin.approve(bToken.address, web3.utils.toWei(10000));
    //mint 10
    await bToken.mint(web3.utils.toWei(10));
  });

  // Test redeem
  describe("Swap Btoken To Get Stable", async () => {
    it("you have btoken and you want stable", async () => {
      assert.equal(true, await bToken.isBToken());
      //approve transaction
      await stableCoin.approve(bToken.address, web3.utils.toWei(10000));
      //redeem 10
      await bToken.redeem(web3.utils.toWei(5));
      await bToken.redeemUnderlying(web3.utils.toWei(5));

      //load your amount of stable
      let accountBalanceOfStable = (
        await stableCoin.balanceOf(accounts[0])
      ).toNumber();
      //load your amount of Btoken
      let accountBalanceOfBToken = (
        await bToken.balanceOf(accounts[0])
      ).toNumber();

      console.log("Stable in account[0]:",web3.utils.fromWei(accountBalanceOfStable))
      console.log("BToken in account[0]:",web3.utils.fromWei(accountBalanceOfBToken))
      assert.equal(100000, web3.utils.fromWei(accountBalanceOfStable));
      assert.equal(0, web3.utils.fromWei(accountBalanceOfBToken));
    });
  });
});

  contract("Borrow Asset", (accounts) => {

    let comptroller, stableCoin, bToken;
  
    before(async () => {
      //contract load
      comptroller = await Comptroller.new();
      //create a stable Coin
      stableCoin = await StableCoin.new("Mock USDT", "mUsdt", 18, web3.utils.toWei(1000000000000));
      //transfer some Liquidity to admin
      await stableCoin.adminTransfer(accounts[0], web3.utils.toWei(10000));
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
      await stableCoin.approve(bToken.address, web3.utils.toWei(10000));
      
      //mint 10
      await bToken.mint(web3.utils.toWei(10));
    });
  
    // Test redeem
    describe("Borrow Btoken for Stable", async () => {
      it("If you have minted you can borrow ", async () => {
        assert.equal(true, await bToken.isBToken());
        await bToken.borrow(web3.utils.toWei(5));
  
        //load your amount of stable
        let accountBalanceOfStable = (await stableCoin.balanceOf(accounts[0])).toNumber();
        //load your amount of Btoken
        let accountBalanceOfBToken = (await bToken.balanceOf(accounts[0])).toNumber();
  
        console.log("Stable in account[0]:",web3.utils.fromWei(accountBalanceOfStable))
        console.log("BToken in account[0]:",web3.utils.fromWei(accountBalanceOfBToken))

        assert.equal(99995, web3.utils.fromWei(accountBalanceOfStable));
        assert.equal(10, web3.utils.fromWei(accountBalanceOfBToken));

      });

      it("Revert if borrow without enough Collateral", async () => {
        assert.equal(true, await bToken.isBToken());
        //borrow 10
        await truffleAssert.reverts(
          bToken.borrow(web3.utils.toWei(10000000000000000)),
          "revert",
          "Error: contract does not revert transaction"
        );
      });
    });
  });

