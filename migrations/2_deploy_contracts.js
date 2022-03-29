const DaiToken = artifacts.require("DaiToken");
const DappToken = artifacts.require("DappToken");
const TokenFarm = artifacts.require("TokenFarm");

module.exports = async function(deployer, network, accounts) {
  
  //deploy dappToken
  await deployer.deploy(DappToken)
  const dappToken = await DappToken.deployed()


  //deploy daiToken 
  await deployer.deploy(DaiToken)
  const daiToken = await DaiToken.deployed()
  
  //deploy token Farm
  await deployer.deploy(TokenFarm, DappToken.address, DaiToken.address)
  const tokenFarm = await TokenFarm.deployed()

  //transfer all asset into Token Farm
  await dappToken.transfer(tokenFarm.address, '1000000000000000000000000')  

  //Transfer 100 Mock Dai tokens to investor account
  await daiToken.transfer(accounts[1], '100000000000000000000')  


};
