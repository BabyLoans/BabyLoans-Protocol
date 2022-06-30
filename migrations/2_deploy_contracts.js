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
    await deployer.deploy(
      StableCoin,
      "Usdt",
      "Usdt",
      18,
      web3.utils.toWei("1000000000000")
    );
    let stableCoin = await StableCoin.deployed();
    stableCoin.adminTransfer(
      accounts[0],
      web3.utils.toWei("10000")
    );
  }

  // Deploy Comptroller
  await deployer.deploy(Comptroller);
  let comptroller = await Comptroller.deployed();

  // Deploy BUSDT
  await deployer.deploy(
    BTokenImmutable,
    StableCoin.address,
    Comptroller.address,
    "bUsdt",
    "bUsdt",
    18,
    accounts[0]
  );
  let bToken = await BTokenImmutable.deployed();

  await comptroller._supportMarket(bToken.address);
};
