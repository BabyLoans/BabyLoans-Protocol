// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./IBEP20.sol";
import "./BTokenInterfaces.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract BToken is Ownable, BTokenInterface {
    constructor(
        address underlyingContract_,
        string memory name_,
        string memory symbol_,
        uint8 decimal_
    ) {
        underlyingContract = underlyingContract_;
        name = name_;
        symbol = symbol_;
        decimals = decimal_;
    }

    /** Admin functions */

    function changeUnderlyingContract(address newUnderlyingContract)
        external
        onlyOwner
    {
        underlyingContract = newUnderlyingContract;
    }

    /** Users functions */

    function transfer(address dst, uint256 amount)
        public
        override
        returns (bool success)
    {
        return transferFrom(msg.sender, dst, amount);
    }

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) public override returns (bool success) {
        require(amount > 0, "amount must be greater than 0");
        require(src != dst, "cannot transfer to self");

        uint256 balance = balanceOf(src);
        require(balance >= amount, "not enough balance");

        uint256 allowances = transferAllowances[src][msg.sender];
        require(allowances >= amount, "not enough allowance");

        accountTokens[src] -= amount;
        accountTokens[dst] += amount;
        transferAllowances[src][msg.sender] -= amount;

        emit Transfer(src, dst, amount);
        return true;
    }

    /**
     * @notice Get the token balance of the `owner`
     * @param owner The address of the account to query
     * @return The number of tokens owned by `owner`
     */
    function balanceOf(address owner) public view override returns (uint256) {
        return accountTokens[owner];
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param amount The number of tokens that are approved (-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        address src = msg.sender;
        transferAllowances[src][spender] = amount;
        emit Approval(src, spender, amount);
        return true;
    }

    /**
     * @notice Get the current allowance from `owner` for `spender`
     * @param owner The address of the account which owns the tokens to be spent
     * @param spender The address of the account which may transfer tokens
     * @return The number of tokens allowed to be spent (-1 means infinite)
     */
    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return transferAllowances[owner][spender];
    }

    /**
     * @notice Mint tokens for the minter
     */
    function mint(address minter, uint256 amount)
        public
        override
        returns (bool)
    {
        require(amount > 0, "amount must be greater than 0");

        IBEP20 tokenContract = IBEP20(underlyingContract);

        bool success = tokenContract.transferFrom(
            minter,
            address(this),
            amount
        );

        if (!success) {
            return false;
        }

        accountTokens[minter] += amount;
        emit Mint(minter, amount, amount);
        return true;
    }

    /**
     * @notice Burn tokens for the minter
     */
    function burn(address burner, uint256 amount)
        public
        override
        returns (bool)
    {
        require(amount > 0, "amount must be greater than 0");

        IBEP20 tokenContract = IBEP20(underlyingContract);

        bool success = tokenContract.transfer(burner, amount);

        if (!success) {
            return false;
        }

        accountTokens[burner] -= amount;
        emit Burn(burner, amount, amount);
        return true;
    }
}
