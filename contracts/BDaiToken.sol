pragma solidity >=0.7.0 <0.9.0;

import "./BToken.sol";

contract BDaiToken is BToken {
    /**
     * @notice Construct a new VBNB money market
     */
    constructor() {
        name = "bDai";
        symbol = "bDai";
        decimals = 18;
    }
}
