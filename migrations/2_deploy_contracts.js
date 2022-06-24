const BDaiToken = artifacts.require("BDaiToken");
const BUsdtToken = artifacts.require("BUsdtToken");
const BUsdcToken = artifacts.require("BUsdcToken");
const TokenLending = artifacts.require("TokenLending");

module.exports = async function (deployer, network, accounts) {
  //deploy BDaiToken
  await deployer.deploy(BDaiToken);
  const bDaiToken = await BDaiToken.deployed();

  //deploy BUsdtToken
  await deployer.deploy(BUsdtToken);
  const bUsdtToken = await BUsdtToken.deployed();

  //deploy BUsdcToken
  await deployer.deploy(BUsdcToken);
  const bUsdcToken = await BUsdcToken.deployed();

  //deploy TokenLending
  await deployer.deploy(
    TokenLending,
    BDaiToken.address,
    BUsdtToken.address,
    BUsdcToken.address
  );
  const tokenLending = await TokenLending.deployed();
};
