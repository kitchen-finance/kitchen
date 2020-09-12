pragma solidity =0.5.4;

import "Pool.sol";

contract PearlPool is Pool {
    constructor() public Pool(address(0x4148C125E0D3C626842BF7180C85E79F97AE524E91),  3125*10**14, true, 1599724800, 1e12, 9 seconds, 9600) {}
}
