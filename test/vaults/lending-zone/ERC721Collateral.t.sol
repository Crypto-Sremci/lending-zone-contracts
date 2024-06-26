// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {MockERC721} from "solmate/test/utils/mocks/MockERC721.sol";
import "evc/EthereumVaultConnector.sol";
import "../../../src/vaults/solmate/VaultRegularBorrowable.sol";
import {IRMMock} from "../../mocks/IRMMock.sol";
import {PriceOracleMock} from "../../mocks/PriceOracleMock.sol";
import {ERC721PriceOracleMock} from "../../../src/vaults/lending-zone/ERC721PriceOracleMock.sol";
import {ERC721Vault} from "../../../src/vaults/lending-zone/ERC721Vault.sol";
import {VaultERC721Borrowable} from "../../../src/vaults/lending-zone/VaultERC721Borrowable.sol";
import "forge-std/console.sol";


/**
* Scenario *
* 1. Create ERC721 vault for collateral
* 2. Create VaultRegularBorrowable
* 3. set price for both vaults
 */

contract ERC721CollateralTest is Test {
    IEVC evc;
    MockERC20 referenceAsset;
    MockERC20 liabilityAsset;
    MockERC721 collateralAsset;
    IRMMock irm;
    PriceOracleMock oracle;
    ERC721PriceOracleMock erc721_oracle;

    VaultERC721Borrowable liabilityVault;
    ERC721Vault collateralVault;
    ERC721Vault collateralVault2;

    function setUp() public {
        evc = new EthereumVaultConnector();
        referenceAsset = new MockERC20("Reference Asset", "RA", 18);
        liabilityAsset = new MockERC20("Liability Asset", "LA", 18);
        collateralAsset = new MockERC721("Collateral Asset", "CA");
        irm = new IRMMock();
        oracle = new PriceOracleMock();
        erc721_oracle = new ERC721PriceOracleMock();

        liabilityVault = new VaultERC721Borrowable(address(evc), liabilityAsset, irm, oracle, erc721_oracle, liabilityAsset, "Liability Vault", "LV");

        oracle.setResolvedAsset(address(liabilityVault));
        oracle.setPrice(address(liabilityAsset), address(referenceAsset), 1e17);

        irm.setInterestRate(10); // 10% APY
    }

    // function mintAndApprove(address alice, address bob) public {
    //     liabilityAsset.mint(alice, 100e18);
    //     collateralAsset1.mint(bob, 100e18);
    //     collateralAsset2.mint(bob, 100e6);
    //     assertEq(liabilityAsset.balanceOf(alice), 100e18);
    //     assertEq(collateralAsset1.balanceOf(bob), 100e18);
    //     assertEq(collateralAsset2.balanceOf(bob), 100e6);

    //     vm.prank(alice);
    //     liabilityAsset.approve(address(liabilityVault), type(uint256).max);

    //     vm.prank(bob);
    //     collateralAsset1.approve(address(collateralVault1), type(uint256).max);

    //     vm.prank(bob);
    //     collateralAsset2.approve(address(collateralVault2), type(uint256).max);
    // }

    function test_borrowAgainstNFT(address alice, address bob) public {
        /// MINT ASSETS
        collateralAsset.mint(alice, 1);
        collateralAsset.mint(alice, 2);
        collateralAsset.mint(bob, 3);
        collateralAsset.mint(bob, 4);
        
        erc721_oracle.setPrice(address(liabilityAsset), address(collateralAsset), 1, 50e18);
        erc721_oracle.setPrice(address(liabilityAsset), address(collateralAsset), 2, 70e18);
        erc721_oracle.setPrice(address(liabilityAsset), address(collateralAsset), 3, 10e18);
        erc721_oracle.setPrice(address(liabilityAsset), address(collateralAsset), 4, 10e18);

        console.log("ORACLE BASE ASSET USDC: ", address(liabilityAsset));
        // assertEq(erc721_oracle.getQuote(address(liabilityAsset), address(collateralAsset), 3), 80e18);

        vm.prank(bob);
        collateralVault = new ERC721Vault(address(evc), collateralAsset, 3);
        vm.prank(bob);
        collateralVault2 = new ERC721Vault(address(evc), collateralAsset, 4);

        assertEq(collateralAsset.ownerOf(1), alice);
        assertEq(collateralAsset.ownerOf(3), bob);

        liabilityAsset.mint(alice, 100e18);
        assertEq(liabilityAsset.balanceOf(alice), 100e18);

        vm.prank(alice);
        liabilityAsset.approve(address(liabilityVault), 100e18);
        vm.prank(alice);
        liabilityVault.deposit(30e18, alice);

        vm.expectRevert(abi.encodeWithSelector(EVCUtil.ControllerDisabled.selector));
        vm.prank(bob);
        liabilityVault.borrow(10e18, bob);

        vm.prank(bob);
        evc.enableController(bob, address(liabilityVault));

        vm.prank(bob);
        collateralAsset.approve(address(collateralVault), 3);
        vm.prank(bob);
        collateralAsset.approve(address(collateralVault2), 4);

        vm.prank(bob);
        collateralVault.deposit();

        vm.prank(bob);
        collateralVault2.deposit();

        vm.prank(bob);
        collateralVault.withdraw(bob);

        vm.prank(bob);
        collateralAsset.approve(address(collateralVault), 3);

        vm.prank(bob);
        collateralVault.deposit();

        console.log("Owner of ERC721: ", collateralAsset.ownerOf(3));
        console.log("Collateral Vault: ", address(collateralVault));

        assertEq(collateralAsset.ownerOf(3), address(collateralVault));

        vm.prank(bob);
        evc.enableCollateral(bob, address(collateralVault));
        vm.prank(bob);
        evc.enableCollateral(bob, address(collateralVault2));

        vm.prank(bob);
        liabilityVault.borrow(10e18, bob);
        console.log("Bob finished borrow"); 

        // assertEq(liabilityVault.debtOf(bob), 80e18);

        // assertEq(liabilityAsset.balanceOf(bob), 80e18);

        vm.prank(bob);
        liabilityAsset.approve(address(liabilityVault), 10000e18);

        vm.prank(bob);
        liabilityVault.repay(10e18, bob);

        vm.prank(bob);
        liabilityVault.disableController();
    }

    

}
