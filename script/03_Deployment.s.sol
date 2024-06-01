// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "solmate/test/utils/mocks/MockERC20.sol";
import "solmate/test/utils/mocks/MockERC721.sol";
import "evc/EthereumVaultConnector.sol";
import "../src/vaults/solmate/VaultRegularBorrowable.sol";
import {ERC721Vault} from "../src/vaults/lending-zone/ERC721Vault.sol";
import {ERC721Collateral} from "../src/vaults/lending-zone/ERC721Collateral.sol";
import {ERC721PriceOracleMock} from "../src/vaults/lending-zone/ERC721PriceOracleMock.sol";
import "../src/view/BorrowableVaultLensForEVC.sol";
import {IRMMock} from "../test/mocks/IRMMock.sol";
import {PriceOracleMock} from "../test/mocks/PriceOracleMock.sol";

/// @title Deployment script
/// @notice This script is used for deploying the EVC and a couple vaults for testing purposes
contract Deployment is Script {
    address evc;
    address irm;
    address usdc_aave;
    address oracle;
    function run() public {
        uint deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        evc = 0xe7f9184428c919346aEbEEc249b653399573Ccf0;
        irm = 0x7c8540D5f540A7278C93D301d5Cb8aE37f09508f;
        usdc_aave = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;
        oracle = 0x19E74257F87584d6c28b6bA84FDC76B9e075319a;

        ERC721PriceOracleMock erc721_oracle = new ERC721PriceOracleMock();

        MockERC721 erc721Collateral = new MockERC721("New Collection", "NC");
        erc721Collateral.mint(0x38F4152654AaBFA65f0de2296327927FBBA8a381, 1);
        erc721Collateral.mint(0x5602157948D0dC97de619C7535F1C9345740E05f, 2);

        // deploy vaults
        ERC721Vault vault1 = new ERC721Vault(evc, erc721Collateral, 1);

        // setup the price oracle
        erc721_oracle.setPrice(usdc_aave, address(erc721Collateral), 1, 100e6);
        erc721_oracle.setPrice(usdc_aave, address(erc721Collateral), 2, 200e6);

        vm.stopBroadcast();

        // display the addresses
        console.log("Vault Asset 1", address(vault1));
    }
}
