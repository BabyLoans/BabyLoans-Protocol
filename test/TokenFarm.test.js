const DaiToken = artifacts.require("DaiToken");
const DappToken = artifacts.require("DappToken");
const TokenFarm = artifacts.require("TokenFarm");

require('chai')
	.use(require('chai-as-promised'))
	.should()

function tokens(n){
	return web3.utils.toWei(n, "ether");
}

contract('TokenFarm', ([owner, investor]) => {
	//write test inside here....

	let daiToken, dappToken, tokenFarm

	before(async () => {
		//contract load 
		daiToken = await DaiToken.new()
		dappToken = await DappToken.new()
		tokenFarm = await TokenFarm.new(dappToken.address, daiToken.address)
	
		//transfer all Dapp tokens to farm (1 millions)
		await dappToken.transfer(tokenFarm.address, tokens('1000000'))

		//Send tokens to the investor
		await dappToken.transfer(investor, tokens('100'), { from:owner })

	})



	describe('Mock Dai deployment', async ()=> {
		it('has a name', async ()=>{
			const name = await daiToken.name()
			assert.equal(name, "Mock DAI Token")
		})
	})

	describe('Dapp Token deployment', async ()=> {
		it('has a name', async ()=>{
			const name = await dappToken.name()
			assert.equal(name, "Dapp Test Token")
		})
	})

	describe('Farming Token', async () => {
		it('rewards investors for staking mDai tokens', async ()=> {
			//Check investor balance before staking 
			result = await daiToken.balanceOf(invesor)
			assert.equal(result.toString(), tokens('100'))
		})
	})
})