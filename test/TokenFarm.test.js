const DaiToken = artifacts.require("DaiToken")
const DappToken = artifacts.require("DappToken")
const TokenFarm = artifacts.require("TokenFarm")

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


	//test Mock Dai deployement 
	describe('Mock Dai deployment', async ()=> {
		it('has a name', async ()=>{
			const name = await daiToken.name()
			assert.equal(name, "Mock DAI Token")
		})
	})

	//test DappToken deployement 
	describe('Dapp Token deployment', async ()=> {
		it('has a name', async ()=>{
			const name = await dappToken.name()
			assert.equal(name, "BabyLoans")
		})

		it('contract has tokens', async()=>{
			let balance = await dappToken.balanceOf(tokenFarm.address)
			assert.equal(balance.toString(), tokens('100000'))
		})
	})

	//Test Farming Token
	describe('Farming Token', async () => {
		it('rewards investors for staking mDai tokens', async ()=> {
			let result 

			//Check investor balance before staking 
			result = await daiToken.balanceOf(investor)
			assert.equal(result.toString(), tokens('10'), 'investor mock dai wallet balance correct before staking')
			
			// Stake Mock Dai Tokens
			await daiToken.approve(tokenFarm.address, tokens('100'), {from: investor})
			await tokenFarm.stakeTokens(token('100'), {from: investor})

			result = await daiToken.balanceOf(investor)
			assert.equal(result.toString(), tokens('0'), 'investor Mock DAI wallet balance correct after staking')
		})
	})
})