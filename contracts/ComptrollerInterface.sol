// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./BToken.sol";

contract ComptrollerStorage {
    /**
     * @notice Per-account mapping of "assets you are in", capped by maxAssets
     */
    mapping(address => BToken[]) public accountAssets;

    address public admin;

    struct Market {
        // Whether or not this market is listed
        bool isListed;
        //  Multiplier representing the most one can borrow against their collateral in this market.
        //  For instance, 0.9 to allow borrowing 90% of collateral value.
        //  Must be between 0 and 1, and stored as a mantissa.
        uint256 collateralFactorMantissa;
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

    // @notice Borrow caps enforced by borrowAllowed for each cToken address. Defaults to zero which corresponds to unlimited borrowing.
    mapping(address => uint256) public borrowCaps;

    /// @notice A list of all markets
    BToken[] public allMarkets;

    enum Error {
        NO_ERROR,
        MARKET_NOT_LISTED,
        MARKET_ALREADY_LISTED,
        GET_ACCOUNT_INFO_ERROR,
        INSUFFICIENT_LIQUIDITY,
        NONZERO_BORROW_BALANCE,
        REJECTION,
        UNAUTHORIZED
    }
}

abstract contract ComptrollerInterface is ComptrollerStorage {
    /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;

    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata bTokens)
        external
        virtual
        returns (uint256[] memory);

    function exitMarket(address bToken) external virtual returns (uint256);

    /*** Policy Hooks ***/

    function mintAllowed(
        address bToken,
        address minter,
        uint256 mintAmount
    ) external virtual returns (uint256);

    function redeemAllowed(
        address bToken,
        address redeemer,
        uint256 redeemTokens
    ) external virtual returns (uint256);

    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external virtual;

    function borrowAllowed(
        address bToken,
        address borrower,
        uint256 borrowAmount
    ) external virtual returns (uint256);

    function repayBorrowAllowed(
        address bToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external virtual returns (uint256);

    // function liquidateBorrowAllowed(
    //     address bTokenBorrowed,
    //     address bTokenCollateral,
    //     address liquidator,
    //     address borrower,
    //     uint repayAmount) virtual external returns (uint);

    // function seizeAllowed(
    //     address bTokenCollateral,
    //     address bTokenBorrowed,
    //     address liquidator,
    //     address borrower,
    //     uint seizeTokens) virtual external returns (uint);

    function transferAllowed(
        address bToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external virtual returns (uint256);

    /*** Liquidity/Liquidation Calculations ***/

    //     function liquidateCalculateSeizeTokens(
    //         address bTokenBorrowed,
    //         address bTokenCollateral,
    //         uint repayAmount) virtual external view returns (uint, uint);
    //
}
