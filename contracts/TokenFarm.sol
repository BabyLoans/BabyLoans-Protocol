pragma solidity >=0.7.0 <0.9.0;

import "./DappToken.sol";
import "./DaiToken.sol";
		
contract TokenFarm {

	string public name = "BabyLoans Protocol";
	DaiToken public daiToken;
	DappToken public dappToken;

	address[] public stakers;
	mapping(address => uint) public stakingBalance;
	mapping(address => bool) public hasStaked;
	mapping(address => bool) public isStaking;

	constructor(DappToken _dappToken, DaiToken _daiToken) public {
		dappToken = _dappToken;
		daiToken = _daiToken;
	}

	// 1. Stakes Tokens (Deposit)
	function stakeTokens(uint _amount) public {
		
		//transferMock Dai tokens to this contract for staking 
		daiToken.transferFrom(msg.sender, address(this), _amount);
		
		//update staking balance 
		stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

		// Add user to stakers array *only* if they haven't staked already
		if(!hasStaked[msg.sender]){
			stakers.push(msg.sender);
		}

		//update staking status
		isStaking[msg.sender] = true;
		hasStaked[msg.sender] = true;
	}


	// 2. Unstake Tokens (Withdraw)

	// 3. Issuing Tokens (interset)

}