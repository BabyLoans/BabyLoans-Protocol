pragma solidity >=0.7.0 <0.9.0;

import "./BToken.sol";

contract BUsdtToken is BToken {
    // 0x55d398326f99059fF775485246999027B3197955
    /**
     * @notice Construct a new BUsdt money market
     */
    constructor(address underlyingContract) BToken(underlyingContract) {
        name = "bUsdt";
        symbol = "bUsdt";
        decimals = 18;
    }
}
