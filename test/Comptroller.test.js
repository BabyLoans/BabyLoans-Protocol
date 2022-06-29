const { assert } = require("chai");

const Comptroller = artifacts.require("Comptroller"); // the comptroller
const BToken = artifacts.require("BToken"); // the comptroller

require("chai").use(require("chai-as-promised")).should();




contract("Comptroller Test", (accounts) => {
   //write test inside here....

  let comptroller;
  before(async () => {
    //contract load
    comptroller = await Comptroller.new();
  });

   // Test balanceOf
   describe("Comptroller Administration", async () => {
    it("deployer is admin", async () => {
      let admin = await comptroller._isAdmin();
      let adminAddress = await comptroller.admin();
      
      assert.equal(true, admin);
      assert.equal(accounts[0], adminAddress);
    });
  });


});
