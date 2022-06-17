pragma solidity >=0.7.0 <0.9.0;

import "./BDaiToken.sol";
import "./BUsdtToken.sol";
import "./BUsdcToken.sol";

contract TokenLending {
    BDaiToken public bDaiToken;
    BUsdtToken public bUsdtToken;
    BUsdcToken public bUsdcToken;

    constructor(
        BDaiToken dai,
        BUsdtToken usdt,
        BUsdcToken usdc
    ) {
        bDaiToken = dai;
        bUsdtToken = usdt;
        bUsdcToken = usdc;
    }
}
