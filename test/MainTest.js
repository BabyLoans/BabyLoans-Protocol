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
      bToken = await BTokenImmutable.new(stableCoin.address, comptroller.address, "bMUsdt", "bMUsdt", 18,accounts[0])
      assert.equal(true, await bToken.isBToken());    
      //add BToken from new Method
      await comptroller._supportMarket(bToken.address);
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
      bToken = await BTokenImmutable.new(stableCoin.address, comptroller.address, "bMUsdt", "bMUsdt", 18,accounts[0])
      
      //Add BToken to Market Comptroller 
      await comptroller._supportMarket(bToken.address);
    });
  
    // Test addBToken
    describe("Add Supply Stable To Get BToken", async () => {
      it("Should Mint and receive BToken", async () => {
        assert.equal(true, await bToken.isBToken());
        
        await stableCoin.approve(bToken.address, 10000);
        
        let mintResult = await bToken.mint(10);
        
        //load Btoken amount of stable 
        let accountBalanceOfStable = (await stableCoin.balanceOf(accounts[0])).toNumber();
        
        //load Btoken amount of stable 
        let bTokenBalanceOfStable = (await stableCoin.balanceOf(bToken.address)).toNumber();
        
        //load Btoken amount of stable 
        let accountBalanceOfBToken = (await bToken.balanceOf(accounts[0])).toNumber();

        assert.equal(100000 - 10, accountBalanceOfStable);
        assert.equal(10, bTokenBalanceOfStable);
        assert.equal(10, accountBalanceOfBToken);

      });
  
     
    });





  // describe("Supply bMUsdt", async () => {
  //   it("Mint should work", async () => {
  //     await createBMusdtToken();
  //     await stableCoin.approve(bMUsdt.address, 10000);
  //     await tokenLending.mint("bMUsdt", 10);

  //     let bMUsdtBalanceOfMUsdt = (
  //       await stableCoin.balanceOf(bMUsdt.address)
  //     ).toNumber();
  //     let accountBalanceOfMUsdt = (
  //       await stableCoin.balanceOf(accounts[0])
  //     ).toNumber();
  //     let accountBalanceOfBMUsdt = (
  //       await bMUsdt.balanceOf(accounts[0])
  //     ).toNumber();

  //     assert.equal(10, bMUsdtBalanceOfMUsdt);
  //     assert.equal(10, accountBalanceOfBMUsdt);

  //     assert.equal(100000 - 10, accountBalanceOfMUsdt);
  //   });

  //   it("Redeem should work", async () => {
  //     await createBMusdtToken();
  //     await stableCoin.approve(bMUsdt.address, 10000);
  //     // There is already 10 mint because of before test
  //     await tokenLending.redeem("bMUsdt", 5);

  //     let bMUsdtBalanceOfMUsdt = (
  //       await stableCoin.balanceOf(bMUsdt.address)
  //     ).toNumber();
  //     let accountBalanceOfMUsdt = (
  //       await stableCoin.balanceOf(accounts[0])
  //     ).toNumber();
  //     let accountBalanceOfBMUsdt = (
  //       await bMUsdt.balanceOf(accounts[0])
  //     ).toNumber();

  //     assert.equal(5, bMUsdtBalanceOfMUsdt);
  //     assert.equal(5, accountBalanceOfBMUsdt);

  //     assert.equal(100000 - 5, accountBalanceOfMUsdt);
  //   });
  // });
});
