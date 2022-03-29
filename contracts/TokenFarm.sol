pragma solidity >=0.7.0 <0.9.0;

import "./DappToken.sol";
import "./DaiToken.sol";
		
contract TokenFarm {

	string public name = "BabyLoans Protocol";
	DaiToken public daiToken;
	DappToken public dappToken;

	constructor(DappToken _dappToken, DaiToken _daiToken) public {
		dappToken = _dappToken;
		daiToken = _daiToken;
	}

}