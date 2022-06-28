// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./BToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenLending is Ownable {
    mapping(string => BToken) public bTokens;
    mapping(string => bool) public existingBTokens;

    /** Admin functions */

    function addBToken(
        address underlyingContract,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) external onlyOwner {
        BToken bToken = new BToken(underlyingContract, name, symbol, decimals);
        bTokens[name] = bToken;
        existingBTokens[name] = true;
    }

    /** Users functions */

    /**
     * @notice supply token to a given address
     */
    function mint(string memory entry, uint256 amount) external {
        BToken bToken = getBToken(entry);

        bool success = bToken.mint(msg.sender, amount);
        require(success);
    }

    function redeem(string memory entry, uint256 amount) external {
        BToken bToken = getBToken(entry);

        bool success = bToken.burn(msg.sender, amount);
        require(success);
    }

    /** Private function */
    function getBToken(string memory entry) private view returns (BToken) {
        require(existingBTokens[entry]);
        return bTokens[entry];
    }
}
