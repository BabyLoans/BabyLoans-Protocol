const StableCoin = artifacts.require("StableCoin");
const BTokenImmutable = artifacts.require("BTokenImmutable");
const Comptroller = artifacts.require("Comptroller");

module.exports = async function (deployer, network, accounts) {
  /*
  let tokens = [
    {
      name: "bDai",
      symbol: "bDai",
      decimals: 18,
      underlyingContract: "0x1af3f329e8be154074d8769d1ffa4ee058b1dbc3",
    },
    {
      name: "bUsdt",
      symbol: "bUsdt",
      decimals: 18,
      underlyingContract: "0x55d398326f99059ff775485246999027b3197955",
    },
    {
      name: "bUsdc",
      symbol: "bUsdc",
      decimals: 18,
      underlyingContract: "0xba5fe23f8a3a24bed3236f05f2fcf35fd0bf0b5c",
    },
  ];
  */

  if (network != "live") {
    await deployer.deploy(StableCoin, "mUsdt", "mUsdt", 18, 1000000000000);
    await StableCoin.deployed();
  }

  // Deploy Comptroller
  await deployer.deploy(Comptroller);
  await Comptroller.deployed();

  // Deploy BUSDT
  await deployer.deploy(BTokenImmutable, StableCoin.address, Comptroller.address, "bMUsdt", "bMUsdt", 18,accounts[0]);
  await BTokenImmutable.deployed();

};
