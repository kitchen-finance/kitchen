pragma solidity =0.5.4;

import "Pool.sol";

contract USDTPool is Pool {
    constructor() public Pool(address(0x41A614F803B6FD780986A42C78EC9C7F77E6DED13C), 62500000, true, 1599638400) {}
}
