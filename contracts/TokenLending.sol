pragma solidity >=0.7.0 <0.9.0;

import "./BDaiToken.sol";
import "./BUsdtToken.sol";
import "./BUsdcToken.sol";
import "./TokenEntries.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenLending is Ownable {
    mapping(string => bool) public existingEntries;

    mapping(string => TokenEntries) public tokenEntries;

    constructor(
        BDaiToken bDaiToken,
        BUsdtToken bUsdtToken,
        BUsdcToken bUsdcToken
    ) {
        IBEP20 daiContract = IBEP20(0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3);
        IBEP20 usdtContract = IBEP20(
            0x55d398326f99059fF775485246999027B3197955
        );
        IBEP20 usdcContract = IBEP20(
            0xBA5Fe23f8a3a24BEd3236F05F2FcF35fd0BF0B5C
        );

        tokenEntries[daiContract.symbol()] = TokenEntries(
            bDaiToken,
            daiContract
        );

        tokenEntries[usdtContract.symbol()] = TokenEntries(
            bUsdtToken,
            usdtContract
        );

        tokenEntries[usdcContract.symbol()] = TokenEntries(
            bUsdcToken,
            usdcContract
        );

        existingEntries[daiContract.symbol()] = true;
        existingEntries[usdtContract.symbol()] = true;
        existingEntries[usdcContract.symbol()] = true;
    }

    /** Admin functions */

    /**
     * @notice set token contract address for a given token symbol
     */
    function setTokenContractAddressInTokenEntry(
        string memory entry,
        address contractAddress
    ) external onlyOwner {
        TokenEntries storage tokenEntry = getTokenEntry(entry);
        tokenEntry.tokenContract = IBEP20(contractAddress);
    }

    /** Users functions */

    /**
     * @notice supply token to a given address
     */
    function mint(string memory entry, uint256 amount) external {
        TokenEntries storage tokenEntry = getTokenEntry(entry);

        bool success = tokenEntry.bToken.mint(tokenEntry.tokenContract, amount);
        require(success);
    }

    function redeem(string memory entry, uint256 amount) external {
        TokenEntries storage tokenEntry = getTokenEntry(entry);

        bool success = tokenEntry.bToken.burn(tokenEntry.tokenContract, amount);
        require(success);
    }

    /** Private function */
    function getTokenEntry(string memory entry)
        private
        view
        returns (TokenEntries storage)
    {
        require(existingEntries[entry]);

        return tokenEntries[entry];
    }
}
