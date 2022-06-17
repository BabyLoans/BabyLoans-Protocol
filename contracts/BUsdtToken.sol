pragma solidity >=0.7.0 <0.9.0;

import "./BToken.sol";

contract BUsdtToken is BToken {
    /**
     * @notice Construct a new VBNB money market
     */
    constructor() {
        name = "bUsdt";
        symbol = "bUsdt";
        decimals = 18;
    }
}
