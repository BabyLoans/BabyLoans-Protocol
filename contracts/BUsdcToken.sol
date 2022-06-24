pragma solidity >=0.7.0 <0.9.0;

import "./BToken.sol";

contract BUsdcToken is BToken {
    // 0xBA5Fe23f8a3a24BEd3236F05F2FcF35fd0BF0B5C
    /**
     * @notice Construct a new BUsdc money market
     */
    constructor(address underlyingContract) BToken(underlyingContract) {
        name = "bDai";
        symbol = "bDai";
        decimals = 18;
    }
}
