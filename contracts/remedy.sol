pragma solidity 0.5.4;

import 'admin.sol';
import 'ITRC20.sol';

contract AdminRemedy is Admin {
    function adminRemedy() public onlyAdmin returns (bool) {
        address payable admin = address(timeLockedAdmin);
        admin.transfer(address(this).balance);
        return true;
    }

    function adminRemedyAnyTRC20(address contractAddr, uint amount) external onlyAdmin returns (bool) {
        ITRC20 trc20 = ITRC20(contractAddr);
        return trc20.transfer(timeLockedAdmin, amount);
    }
}