//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";

//Factory
import {Factory} from "../contracts/Factory.sol";

//Templates
import {ERC721NFTProduct} from "../contracts/templates/ERC721NFTProduct.sol";
import {ERC1155NFTProduct} from "../contracts/templates/ERC1155NFTProduct.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TestFactory is Test {
    Factory public factoryImple;
    Factory factory;
    ERC721NFTProduct public erc721;
    ERC1155NFTProduct public erc1155;

    address spider = makeAddr("spider");
    address alice = makeAddr("alice");

    uint256 constant STARTING_AMOUNT = 1e18;

    //Roles
    /// Contract administrator role
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    /// Transaction signer role
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    function setUp() public {
        //Fund users
        vm.deal(spider, STARTING_AMOUNT);
        vm.deal(alice, STARTING_AMOUNT);

        //Deploys and initialized the factory contract
        vm.startPrank(spider);
        factoryImple = new Factory();

        bytes memory data = abi.encodeCall(factory.initialize, (spider, alice));
        factory = Factory(address(new ERC1967Proxy(address(factoryImple), data)));
        vm.stopPrank();

        //Deploys the templates
        vm.startPrank(spider);
        erc721 = new ERC721NFTProduct();
        erc1155 = new ERC1155NFTProduct();
        vm.stopPrank();

        //Register The Template
        vm.startPrank(spider);
        factory.registerTemplate(address(erc721));
        vm.stopPrank();
    }

    function test_hash_collision_for_different_functions() public {
        //Arrange
        bytes memory maliciousPayload = hex"deadbeef";

        //deploy() parameters
        string memory templateName = "";
        uint256 templateVersion = uint256(uint160(address(factory))) << 96;
        bytes memory initdata = maliciousPayload;

        bytes memory deploy_bytes = abi.encodePacked(spider, templateName, templateVersion, initdata);

        //call() parameters
        address instance = address(factory);
        bytes memory data = abi.encodePacked(hex"000000000000000000000000", maliciousPayload); // 12 zero bytes prepended

        bytes memory call_bytes = abi.encodePacked(spider, instance, data);

        console.logBytes(deploy_bytes);
        console.logBytes(call_bytes);

        assertEq(deploy_bytes, call_bytes);
    }
}
