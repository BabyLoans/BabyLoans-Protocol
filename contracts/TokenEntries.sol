pragma solidity >=0.7.0 <0.9.0;

import "./BToken.sol";
import "./IBEP20.sol";

struct TokenEntries {
    BToken bToken;
    IBEP20 tokenContract;
}
