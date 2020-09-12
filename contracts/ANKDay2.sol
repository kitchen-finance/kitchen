pragma solidity =0.5.4;

import "Pool.sol";

contract ANKPoolDay2 is Pool {
    constructor() public Pool(address(0x411FEA2987B8385E58E70191247B3D988931BD0982),  3125*10**14, true, 1599811200, 1e12, 9 seconds, 9600) {}
}
