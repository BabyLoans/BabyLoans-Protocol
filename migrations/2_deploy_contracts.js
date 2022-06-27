const BToken = artifacts.require("BToken");
const TokenLending = artifacts.require("TokenLending");

module.exports = async function (deployer, network, accounts) {
  //deploy BDaiToken
  await deployer.deploy(BToken, "bDai", "bDai", 18);
  const bDaiToken = await BToken.deployed();

  //deploy BUsdtToken
  await deployer.deploy(BToken, "bUsdt", "bUsdt", 18);
  const bUsdtToken = await BToken.deployed();

  //deploy BUsdcToken
  await deployer.deploy(BToken, "bUsdc", "bUsdc", 18);
  const bUsdcToken = await BToken.deployed();

  //deploy TokenLending
  await deployer.deploy(
    TokenLending,
    bDaiToken.address,
    bUsdtToken.address,
    bUsdcToken.address
  );
  await TokenLending.deployed();
};
