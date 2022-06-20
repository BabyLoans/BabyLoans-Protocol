pragma solidity >=0.7.0 <0.9.0;

import "./BToken.sol";

contract BDaiToken is BToken {
    // 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3
    /**
     * @notice Construct a new BDAI money market
     */
    constructor(address underlyingContract) BToken(underlyingContract) {
        name = "bDai";
        symbol = "bDai";
        decimals = 18;
    }
}
