// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "solmate/test/utils/mocks/MockERC20.sol";
import "solmate/test/utils/mocks/MockERC721.sol";
import "evc/EthereumVaultConnector.sol";
import "../src/vaults/solmate/VaultRegularBorrowable.sol";
import "../src/view/BorrowableVaultLensForEVC.sol";
import {IRMMock} from "../test/mocks/IRMMock.sol";
import {PriceOracleMock} from "../test/mocks/PriceOracleMock.sol";
import {VaultERC721Borrowable} from "../src/vaults/lending-zone/VaultERC721Borrowable.sol";
import {ERC721PriceOracleMock} from "../src/vaults/lending-zone/ERC721PriceOracleMock.sol";
import {IERC721PriceOracleMock} from "../src/vaults/lending-zone/IERC721PriceOracleMock.sol";
import {ERC721Vault} from "../src/vaults/lending-zone/ERC721Vault.sol";

/// @title Deployment script
/// @notice This script is used for deploying the EVC and a couple vaults for testing purposes
contract Deployment is Script {
    address evc;
    address irm;
    address usdc_aave;
    address oracle;
    address erc721Collateral;
    function run() public {
        uint deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // evc = 0xe7f9184428c919346aEbEEc249b653399573Ccf0;
        // irm = 0x7c8540D5f540A7278C93D301d5Cb8aE37f09508f;
        usdc_aave = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;
        // oracle = 0x19E74257F87584d6c28b6bA84FDC76B9e075319a;
        // erc721Collateral = 0xC1BA3850242763EaF2720B342F8BD43FE59bBA7d;
        IEVC evc = new EthereumVaultConnector();
        IRMMock irm = new IRMMock();
        PriceOracleMock oracle = new PriceOracleMock();
        ERC721PriceOracleMock erc721oracle = new ERC721PriceOracleMock();
        MockERC721 erc721asset = new MockERC721("NFT asset", "NA");

        VaultERC721Borrowable erc721borrowable = new VaultERC721Borrowable(address(evc), MockERC20(usdc_aave), IRMMock(irm), IPriceOracle(oracle), IERC721PriceOracleMock(erc721oracle), MockERC20(usdc_aave), "USDC Vault", "USDCV");
        // VaultRegularBorrowable vault1 = new VaultRegularBorrowable(address(evc), MockERC20(usdc_aave), IRMMock(irm), PriceOracleMock(oracle) , MockERC20(usdc_aave), "Usdc vault", "USDCV");

        ERC721Vault erc721vault = new ERC721Vault(address(evc), MockERC721(erc721Collateral), 1);

        // erc721oracle.setPrice(usdc_aave, erc721Collateral, 1, 100e6);

        vm.stopBroadcast();

        // display the addresses
        console.log("EVC", address(evc));
        console.log("IRM", address(irm));
        console.log("oracle", address(oracle));
        console.log("erc721oracle", address(erc721oracle));
        console.log("erc721asset", address(erc721asset));
        console.log("erc721borrowable", address(erc721borrowable));
        console.log("erc721vault", address(erc721vault));
    }
}
