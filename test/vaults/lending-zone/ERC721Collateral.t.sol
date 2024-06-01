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

    VaultRegularBorrowable liabilityVault;
    ERC721Vault collateralVault;

    function setUp() public {
        evc = new EthereumVaultConnector();
        referenceAsset = new MockERC20("Reference Asset", "RA", 18);
        liabilityAsset = new MockERC20("Liability Asset", "LA", 18);
        collateralAsset = new MockERC721("Collateral Asset", "CA");
        irm = new IRMMock();
        oracle = new PriceOracleMock();
        erc721_oracle = new ERC721PriceOracleMock();
        //mint few ERC721 tokens

        liabilityVault = new VaultRegularBorrowable(
            address(evc), liabilityAsset, irm, oracle, referenceAsset, "Liability Vault", "LV"
        );

        collateralVault = new ERC721Vault(address(evc), collateralAsset);

        irm.setInterestRate(10); // 10% APY
    }

    function mintAndPrice(address alice, address bob) public {
        collateralAsset.mint(alice, 1);
        collateralAsset.mint(alice, 2);
        collateralAsset.mint(bob, 3);

        oracle.setResolvedAsset(address(liabilityVault));
        oracle.setPrice(address(liabilityAsset), address(referenceAsset), 1e17);
        
        erc721_oracle.setPrice(address(referenceAsset), address(collateralAsset), 1, 1e18);
        erc721_oracle.setPrice(address(referenceAsset), address(collateralAsset), 2, 2e18);
        erc721_oracle.setPrice(address(referenceAsset), address(collateralAsset), 3, 3e18);

        liabilityAsset.mint(alice, 100e18);
        assertEq(liabilityAsset.balanceOf(alice), 100e18);
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

}
