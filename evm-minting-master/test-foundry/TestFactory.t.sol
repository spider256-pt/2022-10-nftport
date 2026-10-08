//SPDX-License-Identifier: MIT

import {Test, console} from "forge-std/Test.sol";

import {Factory} from "../contracts/Factory.sol";

contract TestFactory is Test {
    Factory public factory;

    address spider = makeAddr("spider");
    address alice = makeAddr("alice");

    function setUp() public {
        vm.startPrank(spider);
        factory = new Factory();
        vm.stopPrank();

        vm.startPrank(spider);
        factory.initialize(spider, alice);
        vm.stopPrank();
    }
}
