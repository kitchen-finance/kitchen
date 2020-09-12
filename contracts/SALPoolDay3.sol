pragma solidity =0.5.4;

import "Pool.sol";

contract SALPoolDay3 is Pool {
    constructor() public Pool(address(0x41F172584249CE9749C1AAB5FD9F04C369B894867A),  2083*10**14, true, 1599897600, 1e12, 9 seconds, 9600) {}
}
