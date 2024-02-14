// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Base
import {BaseTest} from "./BaseTest.t.sol";
import {StdAsserts} from "test/invariants/utils/StdAsserts.sol";
import {VaultRegularBorrowable} from "test/invariants/Setup.t.sol";

/// @title ProtocolAssertions
/// @notice Helper contract for protocol specific assertions
abstract contract ProtocolAssertions is StdAsserts, BaseTest {
    /// @notice returns true if an account is healthy (liability <= collateral)
    function isAccountHealthy(uint256 _liability, uint256 _collateral) internal pure returns (bool) {
        return _liability <= _collateral;
    }

    /// @notice Checks wheter the account is healthy
    function assertAccountIsHealthy(address _vault, address _account) internal {
        (uint256 liabilityValue, uint256 collateralValue) =
            VaultRegularBorrowable(_vault).getLiabilityAndCollateral(_account);
        assertLe(liabilityValue, collateralValue, "Account is unhealthy");
    }
}
