pragma solidity >=0.7.0 <0.9.0;

import "./IBEP20.sol";
import "./BTokenInterfaces.sol";

abstract contract BToken is BTokenInterface {
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

        uint256 allowance = transferAllowances[src][msg.sender];
        require(allowance >= amount, "not enough allowance");

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
    function mint(IBEP20 tokenContract, uint256 amount)
        public
        override
        returns (bool)
    {
        require(amount > 0, "amount must be greater than 0");
        bool success = tokenContract.transferFrom(
            msg.sender,
            address(this),
            amount
        );

        if (success) {
            return false;
        }

        accountTokens[msg.sender] += amount;
        return true;
    }

    /**
     * @notice Burn tokens for the minter
     */
    function burn(IBEP20 tokenContract, uint256 amount)
        public
        override
        returns (bool)
    {
        require(amount > 0, "amount must be greater than 0");
        bool success = tokenContract.transferFrom(
            address(this),
            msg.sender,
            amount
        );

        if (success) {
            return false;
        }

        accountTokens[msg.sender] -= amount;
        return true;
    }
}
