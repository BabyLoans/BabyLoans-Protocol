// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./IBEP20.sol";
import "./BTokenInterfaces.sol";
import "./ComptrollerInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BToken is BTokenInterface {

    function initialize(
        address underlyingContract_,
        ComptrollerInterface comptroller_,
        string memory name_,
        string memory symbol_,
        uint8 decimal_
    ) public {

        require(msg.sender == admin, "only admin may initialize the market");
        require(accrualBlockNumber == 0 && borrowIndex == 0, "market may only be initialized once");
        
        // Set the comptroller
        uint err = _setComptroller(comptroller_);
        require(err == 0, "setting comptroller failed");
        comptroller = comptroller_;

        // Initialize block number and borrow index (block number mocks depend on comptroller being set)
        accrualBlockNumber = _getBlockNumber();

        name = name_;
        symbol = symbol_;
        decimals = decimal_;
        
        // Set underlying and sanity check it
        underlying = underlyingContract_;
        IBEP20(underlying).totalSupply();
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

    /*** User Interface ***/

    /**
     * @notice Sender supplies assets into the market and receives cTokens in exchange
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param mintAmount The amount of the underlying asset to supply
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function mint(uint mintAmount) override external returns (uint) {
        mintInternal(mintAmount);
        return 0;
    }


     /**
     * @notice Sender redeems cTokens in exchange for the underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemTokens The number of cTokens to redeem into underlying
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function redeem(uint redeemTokens) override external returns (uint) {
        redeemInternal(redeemTokens);
        return 0;
    }

     /**
     * @notice Sender redeems cTokens in exchange for the underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemAmount The number of cTokens to redeem into underlying
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function redeemUnderlying(uint redeemAmount) override external returns (uint) {
         redeemUnderlyingInternal(redeemAmount);
        return 0;
    }
    


        /**
     * @notice Applies accrued interest to total borrows and reserves
     * @dev This calculates interest accrued from the last checkpointed block
     *   up to the current block and writes new checkpoint to storage.
     */
    function accrueInterest() virtual override public returns (uint) {
        /* Remember the initial block number */
        uint currentBlockNumber = _getBlockNumber();
        uint accrualBlockNumberPrior = accrualBlockNumber;

        /* Short-circuit accumulating 0 interest */
        if (accrualBlockNumberPrior == currentBlockNumber) {
            // return 0;
        }

        //TODO ADD INTEREST CALCULATION

        /* We write the previously calculated values into storage */
        accrualBlockNumber = currentBlockNumber;
        
        /* We emit an AccrueInterest event */
        emit AccrueInterest(getCashPrior(), 0, 0, 0);

        return 0;
    }


      /**
     * @notice Sender supplies assets into the market and receives cTokens in exchange
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param mintAmount The amount of the underlying asset to supply
     */
    function mintInternal(uint mintAmount) internal{
        //TODO ADD INTEREST
        accrueInterest();

        // mintFresh emits the actual Mint event if successful and logs on errors, so we don't need to
        mintFresh(msg.sender, mintAmount);
    }

    
    /**
     * @notice Sender redeems cTokens in exchange for the underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemTokens The number of cTokens to redeem into underlying
     */
    function redeemInternal(uint redeemTokens) internal{  // TODO nonReentrant {
        //TODO ADD INTEREST
        accrueInterest();
        // redeemFresh emits redeem-specific logs on errors, so we don't need to
        redeemFresh(payable(msg.sender), redeemTokens, 0);
    }

    /**
     * @notice Sender redeems cTokens in exchange for the underlying asset
     * @dev Accrues interest whether or not the operation succeeds, unless reverted
     * @param redeemAmount The number of cTokens to redeem into underlying
     */
    function redeemUnderlyingInternal(uint redeemAmount) internal{  // TODO nonReentrant {
        //TODO ADD INTEREST
        accrueInterest();
        // redeemFresh emits redeem-specific logs on errors, so we don't need to
        redeemFresh(payable(msg.sender), 0, redeemAmount);
    }

    /**
     * @notice Sender borrows assets from the protocol to their own address
     * @param borrowAmount The amount of the underlying asset to borrow
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function borrow(uint borrowAmount) override external returns (uint) {
        borrowInternal(borrowAmount);
        return 0;
    }

    /**
     * @notice Sender repays their own borrow
     * @param repayAmount The amount to repay, or -1 for the full outstanding amount
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function repayBorrow(uint repayAmount) override external returns (uint) {
        repayBorrowInternal(repayAmount);
        return 0;
    }

    /**
     * @notice Sender repays a borrow belonging to borrower
     * @param borrower the account with the debt being payed off
     * @param repayAmount The amount to repay, or -1 for the full outstanding amount
     * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
     */
    function repayBorrowBehalf(address borrower, uint repayAmount) override external returns (uint) {
        repayBorrowBehalfInternal(borrower, repayAmount);
        return 0;
    }


      /**
     * @notice User supplies assets into the market and receives cTokens in exchange
     * @dev Assumes interest has already been accrued up to the current block
     * @param minter The address of the account which is supplying the assets
     * @param mintAmount The amount of the underlying asset to supply
     */
    function mintFresh(address minter, uint mintAmount) internal {
        /* Fail if mint not allowed */
        uint allowed = comptroller.mintAllowed(address(this), minter, mintAmount);
        require(allowed == 0, "MINT NOT ALLOWED");

        /* Verify market's block number equals current block number */
        require(accrualBlockNumber == _getBlockNumber(), "NOT THE SAME BLOCK NUMBER");
        
        uint actualMintAmount = doTransferIn(minter, mintAmount);
        //TODO EXCHANGERATE
        //uint mintTokens = div_(actualMintAmount, exchangeRate);
        uint mintTokens =  actualMintAmount;

        /* We calculate the new total supply of cTokens and minter token balance, checking for overflow: */
        totalSupply = totalSupply + mintTokens;
        accountTokens[minter] = accountTokens[minter] + mintTokens;

        /* We emit a Mint event, and a Transfer event */
        emit Mint(minter, actualMintAmount, mintTokens);
        emit Transfer(address(this), minter, mintTokens);

    }

    /**
     * @notice User redeems cTokens in exchange for the underlying asset
     * @dev Assumes interest has already been accrued up to the current block
     * @param redeemer The address of the account which is redeeming the tokens
     * @param redeemTokensIn The number of cTokens to redeem into underlying (only one of redeemTokensIn or redeemAmountIn may be non-zero)
     * @param redeemAmountIn The number of underlying tokens to receive from redeeming cTokens (only one of redeemTokensIn or redeemAmountIn may be non-zero)
     */
    function redeemFresh(address payable redeemer, uint redeemTokensIn, uint redeemAmountIn) internal {
        require(redeemTokensIn == 0 || redeemAmountIn == 0, "one of redeemTokensIn or redeemAmountIn must be zero");

        uint redeemTokens;
        uint redeemAmount;
        /* If redeemTokensIn > 0: */
        if (redeemTokensIn > 0) {
            /*
             * We calculate the exchange rate and the amount of underlying to be redeemed:
             *  redeemTokens = redeemTokensIn
             *  redeemAmount = redeemTokensIn x exchangeRateCurrent
             */
            redeemTokens = redeemTokensIn;
            redeemAmount = redeemTokensIn;
        } else {
            /*
             * We get the current exchange rate and calculate the amount to be redeemed:
             *  redeemTokens = redeemAmountIn / exchangeRate
             *  redeemAmount = redeemAmountIn
             */
            redeemAmount = redeemAmountIn; 
            redeemTokens = redeemAmountIn;
        }

        /* Fail if redeem not allowed */
        uint allowed = comptroller.redeemAllowed(address(this), redeemer, redeemTokens);
        require(allowed == 0, "Redeem Not Allowed");
    
        /* Verify market's block number equals current block number */
        require(accrualBlockNumber == _getBlockNumber(), "Current Block Number not equals");

        /* Fail gracefully if protocol has insufficient cash */
        require(getCashPrior() >= redeemAmount, "Insufficient Cash into protocol");

        /////////////////////////
        // EFFECTS & INTERACTIONS
        // (No safe failures beyond this point)


        /*
         * We write the previously calculated values into storage.
         *  Note: Avoid token reentrancy attacks by writing reduced supply before external transfer.
         */
        totalSupply = totalSupply - redeemTokens;
        accountTokens[redeemer] = accountTokens[redeemer] - redeemTokens;

        /*
         * We invoke doTransferOut for the redeemer and the redeemAmount.
         *  Note: The cToken must handle variations between ERC-20 and ETH underlying.
         *  On success, the cToken has redeemAmount less of cash.
         *  doTransferOut reverts if anything goes wrong, since we can't be sure if side effects occurred.
         */
        doTransferOut(redeemer, redeemAmount);

        /* We emit a Transfer event, and a Redeem event */
        emit Transfer(redeemer, address(this), redeemTokens);
        emit Redeem(redeemer, redeemAmount, redeemTokens);

        /* We call the defense hook */
        comptroller.redeemVerify(address(this), redeemer, redeemAmount, redeemTokens);
    }


     /**
      * @notice Sender borrows assets from the protocol to their own address
      * @param borrowAmount The amount of the underlying asset to borrow
      */
    function borrowInternal(uint borrowAmount) internal { // TODO nonReentrant {
        accrueInterest();
        // borrowFresh emits borrow-specific logs on errors, so we don't need to
        borrowFresh(payable(msg.sender), borrowAmount);
    }

     /**
      * @notice Users borrow assets from the protocol to their own address
      * @param borrowAmount The amount of the underlying asset to borrow
      */
    function borrowFresh(address payable borrower, uint borrowAmount) internal {
        /* Fail if borrow not allowed */
        uint allowed = comptroller.borrowAllowed(address(this), borrower, borrowAmount);
        require(allowed == 0, "Redeem Not Allowed");
    
        /* Verify market's block number equals current block number */
        require(accrualBlockNumber == _getBlockNumber(), "Current Block Number not equals");

        /* Fail gracefully if protocol has insufficient cash */
        require(getCashPrior() > borrowAmount, "Insufficient Cash into protocol");



        /*
         * We calculate the new borrower and total borrow balances, failing on overflow:
         *  accountBorrowNew = accountBorrow + borrowAmount
         *  totalBorrowsNew = totalBorrows + borrowAmount
         */
        uint accountBorrowsPrev = borrowBalanceStoredInternal(borrower);
        uint accountBorrowsNew = accountBorrowsPrev + borrowAmount;
        uint totalBorrowsNew = totalBorrows + borrowAmount;

        /////////////////////////
        // EFFECTS & INTERACTIONS
        // (No safe failures beyond this point)

        /*
         * We write the previously calculated values into storage.
         *  Note: Avoid token reentrancy attacks by writing increased borrow before external transfer.
        `*/
        accountBorrows[borrower].principal = accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = totalBorrowsNew;

        /*
         * We invoke doTransferOut for the borrower and the borrowAmount.
         *  Note: The cToken must handle variations between ERC-20 and ETH underlying.
         *  On success, the cToken borrowAmount less of cash.
         *  doTransferOut reverts if anything goes wrong, since we can't be sure if side effects occurred.
         */
        doTransferOut(borrower, borrowAmount);

        /* We emit a Borrow event */
        emit Borrow(borrower, borrowAmount, accountBorrowsNew, totalBorrowsNew);
    }


    /**
     * @notice Return the borrow balance of account based on stored data
     * @param account The address whose balance should be calculated
     * @return (error code, the calculated balance or 0 if error code is non-zero)
     */
    function borrowBalanceStoredInternal(address account) internal view returns (uint) {
        /* Get borrowBalance and borrowIndex */
        BorrowSnapshot storage borrowSnapshot = accountBorrows[account];

        /* If borrowBalance = 0 then borrowIndex is likely also 0.
         * Rather than failing the calculation with a division by 0, we immediately return 0 in this case.
         */
        if (borrowSnapshot.principal == 0) {
            return 0;
        }

        /* Calculate new borrow balance using the interest index:
         *  recentBorrowBalance = borrower.borrowBalance * market.borrowIndex / borrower.borrowIndex
         */
        uint principalTimesIndex = borrowSnapshot.principal * borrowIndex;
        return principalTimesIndex / borrowSnapshot.interestIndex;
    }


    /**
     * @notice Sender repays their own borrow
     * @param repayAmount The amount to repay, or -1 for the full outstanding amount
     */
    function repayBorrowInternal(uint repayAmount) internal { // TODO nonReentrant {
        accrueInterest();
        // repayBorrowFresh emits repay-borrow-specific logs on errors, so we don't need to
        repayBorrowFresh(msg.sender, msg.sender, repayAmount);
    }

    /**
     * @notice Sender repays a borrow belonging to borrower
     * @param borrower the account with the debt being payed off
     * @param repayAmount The amount to repay, or -1 for the full outstanding amount
     */
    function repayBorrowBehalfInternal(address borrower, uint repayAmount) internal { // TODO nonReentrant {
        accrueInterest();
        // repayBorrowFresh emits repay-borrow-specific logs on errors, so we don't need to
        repayBorrowFresh(msg.sender, borrower, repayAmount);
    }

      /**
     * @notice Borrows are repaid by another user (possibly the borrower).
     * @param payer the account paying off the borrow
     * @param borrower the account with the debt being payed off
     * @param repayAmount the amount of underlying tokens being returned, or -1 for the full outstanding amount
     * @return (uint) the actual repayment amount.
     */
    function repayBorrowFresh(address payer, address borrower, uint repayAmount) internal returns (uint) {
        /* Fail if repayBorrow not allowed */
        uint allowed = comptroller.repayBorrowAllowed(address(this), payer, borrower, repayAmount);
        require(allowed == 0, "Redeem Not Allowed");
    
        /* Verify market's block number equals current block number */
        require(accrualBlockNumber == _getBlockNumber(), "Current Block Number not equals");


        /* We fetch the amount the borrower owes, with accumulated interest */
        uint accountBorrowsPrev = borrowBalanceStoredInternal(borrower);

        /* If repayAmount == -1, repayAmount = accountBorrows */
        uint repayAmountFinal = repayAmount == type(uint).max ? accountBorrowsPrev : repayAmount;

        uint actualRepayAmount = doTransferIn(payer, repayAmountFinal);

        uint accountBorrowsNew = accountBorrowsPrev - actualRepayAmount;
        uint totalBorrowsNew = totalBorrows - actualRepayAmount;

        /* We write the previously calculated values into storage */
        accountBorrows[borrower].principal = accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = totalBorrowsNew;

        /* We emit a RepayBorrow event */
        emit RepayBorrow(payer, borrower, actualRepayAmount, accountBorrowsNew, totalBorrowsNew);

        return actualRepayAmount;
    }






    /*** Safe Token ***/

    /**
     * @notice Gets balance of this contract in terms of the underlying
     * @dev This excludes the value of the current message, if any
     * @return The quantity of underlying tokens owned by this contract
     */
    function getCashPrior() virtual internal view returns (uint) {
        IBEP20 token = IBEP20(underlying);
        return token.balanceOf(address(this));
    }

    /**
     *  Prevent This: https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
     */
    function doTransferIn(address from, uint amount) virtual internal returns (uint) {
        // Read from storage once
        address underlying_ = underlying;
        IBEP20 token = IBEP20(underlying_);
        uint balanceBefore = IBEP20(underlying_).balanceOf(address(this));
        token.transferFrom(from, address(this), amount);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                       // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                      // This is a compliant ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of override external call
                }
                default {                      // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");

        // Calculate the amount that was *actually* transferred
        uint balanceAfter = IBEP20(underlying_).balanceOf(address(this));
        return balanceAfter - balanceBefore;   // underflow already checked above, just subtract
    }

    /**
     *  Prevent This: https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
     */
    function doTransferOut(address payable to, uint amount) virtual internal {
        IBEP20 token = IBEP20(underlying);
        token.transfer(to, amount);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                     // This is a compliant ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of override external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_OUT_FAILED");
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

     /**
     * @notice Get a snapshot of the account's balances, and the cached exchange rate
     * @dev This is used by comptroller to more efficiently perform liquidity checks.
     * @param account Address of the account to snapshot
     * @return (possible error, token balance, borrow balance, exchange rate mantissa)
     */
    function getAccountInfo(address account) override external view returns (uint, uint, uint, uint) {
        return (
            0,
            accountTokens[account],
            borrowBalanceStoredInternal(account),
            //TODO FOR RATE INTEREST
            0
        );
    }







     /**
     * @dev Function to simply retrieve block number
     *  This exists mainly for inheriting test contracts to stub this result.
     */
    function _getBlockNumber() virtual internal view returns (uint) {
        return block.number;
    }

      /**
      * @notice Sets a new comptroller for the market
      * @dev Admin function to set a new comptroller
      * @return uint 0=success, otherwise a failure (see ErrorReporter.sol for details)
      */
    function _setComptroller(ComptrollerInterface newComptroller) override public returns (uint) {
        // Check caller is admin
        require(msg.sender == admin);

        ComptrollerInterface oldComptroller = comptroller;
        // Ensure invoke comptroller.isComptroller() returns true
        require(newComptroller.isComptroller(), "marker method returned false");

        // Set market's comptroller to newComptroller
        comptroller = newComptroller;

        // Emit NewComptroller(oldComptroller, newComptroller)
        emit NewComptroller(oldComptroller, newComptroller);

        return 0;
    }


}
