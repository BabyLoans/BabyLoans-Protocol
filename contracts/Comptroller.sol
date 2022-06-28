// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./BToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ComptrollerStorage {

    /**
     * @notice Per-account mapping of "assets you are in", capped by maxAssets
     */
    mapping(address => BToken[]) public accountAssets;


    struct Market {
        // Whether or not this market is listed
        bool isListed;

        //  Multiplier representing the most one can borrow against their collateral in this market.
        //  For instance, 0.9 to allow borrowing 90% of collateral value.
        //  Must be between 0 and 1, and stored as a mantissa.
        uint collateralFactorMantissa;

        // Per-market mapping of "accounts in this asset"
        mapping(address => bool) accountMembership;

        // Whether or not this market receives COMP
        bool isComped;
    }

    /**
     * @notice Official mapping of BTokens -> Market metadata
     * @dev Used e.g. to determine if a market is supported
     */
    mapping(address => Market) public markets;

    /// @notice A list of all markets
    BToken[] public allMarkets;


    enum Error {
        NO_ERROR,
        MARKET_NOT_LISTED,
        NONZERO_BORROW_BALANCE,
        REJECTION
    }

}


contract Comptroller is ComptrollerStorage{
    
     /**
     * @notice Returns the assets an account has entered
     */
    function getAssetsIn(address account) external view returns (BToken[] memory) {
        BToken[] memory assetsIn = accountAssets[account];

        return assetsIn;
    }

    /**
     * @notice Returns whether the given account is entered in the given asset
     */
    function checkMembership(address account, BToken bToken) external view returns (bool) {
        return markets[address(bToken)].accountMembership[account];
    }

    /**
     * @notice add user bToken to  be included in account liquidity available calculation 
     */
    function enterInMarkets(address[] memory bTokens) public returns (uint[] memory){
        uint len = bTokens.length;

        uint[] memory results = new uint[](len);

        for(uint i=0;i<len;i++){
            BToken btoken = BToken(bTokens[i]);

            results[i] = uint(addTomarketInternal(btoken, msg.sender));
        }

        return results;

    }

    function addTomarketInternal(BToken bToken, address borrower) internal returns (Error){
        Market storage marketToJoin = markets[address(bToken)];
        
        if (!marketToJoin.isListed) {
            // market is not listed, cannot join
            return Error.MARKET_NOT_LISTED;
        }

        if (marketToJoin.accountMembership[borrower] == true) {
            // already joined
            return Error.NO_ERROR;
        }

        //  that is, only when we need to perform liquidity checks
        //  and not whenever we want to check if an account is in a particular market
        marketToJoin.accountMembership[borrower] = true;
        accountAssets[borrower].push(bToken);

        return Error.NO_ERROR;
    }

     function exitMarket(address bTokenAddress) external returns (uint) {
        BToken bToken = BToken(bTokenAddress);
        /* Get sender tokensHeld and amountOwed underlying from the cToken */
        (uint oErr, uint tokensHeld, uint amountOwed) = bToken.getAccountSnapshot(msg.sender);
        require(oErr == 0, "exitMarket: getAccountSnapshot failed"); // semi-opaque error code

        /* Fail if the sender has a borrow balance */
        if (amountOwed != 0) {
            return uint(Error.NONZERO_BORROW_BALANCE);
        }

        /* TODO verify if he can redeem*/
        uint allowed = redeemAllowedInternal(bTokenAddress, msg.sender, tokensHeld);
        if (allowed != 0) {
            return uint(Error.REJECTION);
        }

        Market storage marketToExit = markets[address(bToken)];

        /* Return true if the sender is not already ‘in’ the market */
        if (!marketToExit.accountMembership[msg.sender]) {
            return uint(Error.NO_ERROR);
        }

        /* Set cToken account membership to false */
        delete marketToExit.accountMembership[msg.sender];

        /* Delete cToken from the account’s list of assets */
        // load into memory for faster iteration
        BToken[] memory userAssetList = accountAssets[msg.sender];
        uint len = userAssetList.length;
        uint assetIndex = len;
        for (uint i = 0; i < len; i++) {
            if (userAssetList[i] == bToken) {
                assetIndex = i;
                break;
            }
        }

        // We *must* have found the asset in the list or our redundant data structure is broken
        assert(assetIndex < len);

        // copy last item in list to location of item to be removed, reduce length by 1
        BToken[] storage storedList = accountAssets[msg.sender];
        storedList[assetIndex] = storedList[storedList.length - 1];
        storedList.pop();

        return uint(Error.NO_ERROR);
    }

    function redeemAllowed(address bToken, address redeemer, uint redeemAmount) external returns (uint) {
        uint allowed = redeemAllowedInternal(bToken, redeemer, redeemAmount);
        if (allowed != uint(Error.NO_ERROR)) {
            return allowed;
        }
        return uint(Error.NO_ERROR);
    }


    function redeemAllowedInternal(address bToken, address redeemer, uint redeemAmount) internal view returns(uint){
         if (!markets[bToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }
        if (!markets[bToken].accountMembership[redeemer]) {
            return uint(Error.NO_ERROR);
        }

        

    }


}

