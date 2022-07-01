const StableCoin = artifacts.require("StableCoin");
const BTokenImmutable = artifacts.require("BTokenImmutable");
const Comptroller = artifacts.require("Comptroller");

module.exports = async function (deployer, network, accounts) {
  let usdt = await StableCoin.new(
    "USDT",
    "USDT",
    18,
    web3.utils.toWei("1000000000000")
  );
  usdt.adminTransfer(accounts[0], web3.utils.toWei("10000"));

  let usdc = await StableCoin.new(
    "USDC",
    "USDC",
    18,
    web3.utils.toWei("1000000000000")
  );
  usdc.adminTransfer(accounts[0], web3.utils.toWei("10000"));

  let dai = await StableCoin.new(
    "DAI",
    "DAI",
    18,
    web3.utils.toWei("1000000000000")
  );
  dai.adminTransfer(accounts[0], web3.utils.toWei("10000"));

  // Deploy Comptroller
  await deployer.deploy(Comptroller);
  let comptroller = await Comptroller.deployed();

  // Deploy BUSDT
  let bUSDT = await BTokenImmutable.new(
    usdt.address,
    Comptroller.address,
    "bUSDT",
    "bUSDT",
    18,
    accounts[0]
  );
  await comptroller._supportMarket(bUSDT.address);

  // Deploy BUSDC
  let bUSDC = await BTokenImmutable.new(
    usdc.address,
    Comptroller.address,
    "bUSDC",
    "bUSDC",
    18,
    accounts[0]
  );
  await comptroller._supportMarket(bUSDC.address);

  // Deploy BDAI
  let bDAI = await BTokenImmutable.new(
    dai.address,
    Comptroller.address,
    "bDAI",
    "bDAI",
    18,
    accounts[0]
  );
  await comptroller._supportMarket(bDAI.address);
};
