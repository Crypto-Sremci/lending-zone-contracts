// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "solmate/test/utils/mocks/MockERC20.sol";
import "evc/EthereumVaultConnector.sol";
import "../src/vaults/solmate/VaultRegularBorrowable.sol";
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

        // deploy vaults
        VaultRegularBorrowable vault1 = new VaultRegularBorrowable(evc, MockERC20(usdc_aave), IRMMock(irm), PriceOracleMock(oracle) , MockERC20(usdc_aave), "Usdc vault", "USDCV");

        // setup the vaults
        vault1.setCollateralFactor(address(vault1), 90); // cf = 0.95, self-collateralization

        // setup the price oracle
        PriceOracleMock(oracle).setResolvedAsset(address(vault1));

        vm.stopBroadcast();

        // display the addresses
        console.log("Vault Asset 1", address(vault1));
    }
}
