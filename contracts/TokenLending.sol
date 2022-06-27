pragma solidity >=0.7.0 <0.9.0;

import "./BToken.sol";

contract TokenLending {
    mapping(string => BToken) public bTokens;
    mapping(string => bool) public existingBTokens;

    constructor(
        BToken bDaiToken,
        BToken bUsdtToken,
        BToken bUsdcToken
    ) {
        bTokens["DAI"] = bDaiToken;
        bTokens["USDT"] = bUsdtToken;
        bTokens["USDC"] = bUsdcToken;

        existingBTokens["DAI"] = true;
        existingBTokens["USDT"] = true;
        existingBTokens["USDC"] = true;
    }

    /** Users functions */

    /**
     * @notice supply token to a given address
     */
    function mint(string memory entry, uint256 amount) external {
        BToken bToken = getBToken(entry);

        bool success = bToken.mint(amount);
        require(success);
    }

    function redeem(string memory entry, uint256 amount) external {
        BToken bToken = getBToken(entry);

        bool success = bToken.burn(amount);
        require(success);
    }

    /** Private function */
    function getBToken(string memory entry) private view returns (BToken) {
        require(existingBTokens[entry]);
        return bTokens[entry];
    }
}
