// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

// Libraries
import {ERC20} from "solmate/tokens/ERC20.sol";

// Contracts
import {
    VaultSimple,
    VaultSimpleBorrowable,
    VaultRegularBorrowable,
    VaultBorrowableWETH
} from "../../base/BaseStorage.t.sol";

// Test Contracts
import {VaultBaseGetters} from "../VaultBaseGetters.sol";

// Interfaces
import {IEVC} from "evc/interfaces/IEthereumVaultConnector.sol";
import {IIRM} from "src/interfaces/IIRM.sol";
import {IPriceOracle} from "src/interfaces/IPriceOracle.sol";

/// @title VaultSimpleExtended
/// @notice Extended version of VaultSimple, it implements extra getters
contract VaultSimpleExtended is VaultSimple, VaultBaseGetters {
    constructor(
        IEVC _evc,
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) VaultSimple(_evc, _asset, _name, _symbol) {}
}

/// @title VaultSimpleBorrowableExtended
/// @notice Extended version of VaultSimpleBorrowable, it implements extra getters
contract VaultSimpleBorrowableExtended is VaultSimpleBorrowable, VaultBaseGetters {
    constructor(
        IEVC _evc,
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) VaultSimpleBorrowable(_evc, _asset, _name, _symbol) {}

    function getLastInterestUpdate() external view returns (uint256 lastInterestUpdate_) {
        lastInterestUpdate_ = 0;
    }

    function getOwed(address _borrower) external view returns (uint256 owed_) {
        owed_ = owed[_borrower];
    }
}

/// @title VaultRegularBorrowableExtended
/// @notice Extended version of VaultVaultRegularBorrowableSimple, it implements extra getters
contract VaultRegularBorrowableExtended is VaultRegularBorrowable, VaultBaseGetters {
    constructor(
        IEVC _evc,
        ERC20 _asset,
        IIRM _irm,
        IPriceOracle _oracle,
        ERC20 _referenceAsset,
        string memory _name,
        string memory _symbol
    ) VaultRegularBorrowable(_evc, _asset, _irm, _oracle, _referenceAsset, _name, _symbol) {}

    function getLastInterestUpdate() external view returns (uint256 lastInterestUpdate_) {
        lastInterestUpdate_ = lastInterestUpdate;
    }

    function getOwed(address _borrower) external view returns (uint256 owed_) {
        owed_ = owed[_borrower];
    }

    function getInterestAccumulator() external view returns (uint256 interestAccumulator_) {
        interestAccumulator_ = interestAccumulator;
    }
}

/// @title VaultBorrowableWETHExtended
/// @notice Extended version of VaultBorrowable, it implements extra getters
contract VaultBorrowableWETHExtended is VaultBorrowableWETH, VaultBaseGetters {
    constructor(
        IEVC _evc,
        ERC20 _asset,
        IIRM _irm,
        IPriceOracle _oracle,
        ERC20 _referenceAsset,
        string memory _name,
        string memory _symbol
    ) VaultBorrowableWETH(_evc, _asset, _irm, _oracle, _referenceAsset, _name, _symbol) {}

    function getOwed(address _borrower) external view returns (uint256 owed_) {
        owed_ = owed[_borrower];
    }
}
