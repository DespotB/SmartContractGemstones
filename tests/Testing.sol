// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

library SafeMult {
    function mu(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if(_a== 0){
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }
}

