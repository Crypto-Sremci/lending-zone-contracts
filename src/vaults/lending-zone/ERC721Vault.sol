// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.19;

import "solmate/auth/Owned.sol";
import "solmate/tokens/ERC4626.sol";
import "solmate/tokens/ERC721.sol";
import "solmate/utils/SafeTransferLib.sol";
import "solmate/utils/FixedPointMathLib.sol";
import "../VaultBase.sol";
import {IERC721Receiver} from "openzeppelin/token/ERC721/IERC721Receiver.sol";

interface IERC721Vault {
    function getUnderlyingERC721() view external returns (address, uint256);
}

/// @title ERC721Vault
/// @dev ERC721 contract is used as a collateral for the vault.
/// @notice This is for test purposes only, do not use in production.
contract ERC721Vault is VaultBase, Owned, IERC721Receiver, IERC721Vault {
    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed caller, uint256 id);
    event Withdraw(address indexed caller, address indexed receiver, uint256 id);
    event SupplyCapSet(uint256 newSupplyCap);

    error SnapshotNotTaken();
    error SupplyCapExceeded();

    uint256 public supplyCap;
    uint256 public totalSupply;
    ERC721 public immutable asset;
    uint256 public immutable id;

    constructor(
        address _evc,
        ERC721 _asset,
        uint256 _id
    ) VaultBase(_evc) Owned(msg.sender) {
        asset = _asset;
        id = _id;
    }

    function getUnderlyingERC721() view public returns (address, uint256) {
        return (address(asset), id);
    }

    ///@notice implementing this method to be able to receive ERC721 token
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice Sets the supply cap of the vault (amount of NFTs that someone can deposit into the vault).
    /// @param newSupplyCap The new supply cap.
    function setSupplyCap(uint256 newSupplyCap) external onlyOwner {
        supplyCap = newSupplyCap;
        emit SupplyCapSet(newSupplyCap);
    }

    /// @notice Creates a snapshot of the vault.
    /// @dev This function is called before any action that may affect the vault's state.
    /// @return A snapshot of the vault's state.
    function doCreateVaultSnapshot() internal virtual override returns (bytes memory) {
        // make total supply snapshot here and return it:
        return abi.encode(totalSupply);
    }

    /// @notice Checks the vault's status.
    /// @dev This function is called after any action that may affect the vault's state.
    /// @param oldSnapshot The snapshot of the vault's state before the action.
    function doCheckVaultStatus(bytes memory oldSnapshot) internal virtual override {
        // sanity check in case the snapshot hasn't been taken
        if (oldSnapshot.length == 0) revert SnapshotNotTaken();

        // validate the vault state here:
        uint256 initialSupply = abi.decode(oldSnapshot, (uint256));
        uint256 finalSupply = totalSupply;

        if (supplyCap != 0 && finalSupply > supplyCap && finalSupply > initialSupply) {
            revert SupplyCapExceeded();
        }
    }

    /// @notice Checks the status of an account.
    /// @dev This function is called after any action that may affect the account's state.
    function doCheckAccountStatus(address, address[] calldata) internal view virtual override {
        // no need to do anything here because the vault does not allow borrowing
    }

    /// @notice Disables the controller.
    /// @dev The controller is only disabled if the account has no debt.
    function disableController() external virtual override nonReentrant {
        // this vault doesn't allow borrowing, so we can't check that the account has no debt.
        // this vault should never be a controller, but user errors can happen
        EVCClient.disableController(_msgSender());
    }

    /// @notice Deposits an NFT with the certain id to the receiver.
    function deposit() public virtual callThroughEVC nonReentrant {
        address msgSender = _msgSender();
        require(asset.ownerOf(id) == msgSender, "Not Owner");

        createVaultSnapshot();

        // Need to transfer before minting or ERC777s could reenter.
        asset.safeTransferFrom(msgSender, address(this), id);

        //increase the total amount of deposited NFTs
        totalSupply++;

        emit Deposit(msgSender, id);

        requireVaultStatusCheck();
    }

    /// @notice Withdraws an NFT with certain id.
    /// @param receiver receiver of NFT
    function withdraw(
        address receiver
    ) public virtual callThroughEVC nonReentrant {
        address msgSender = _msgSender();

        createVaultSnapshot();

        asset.safeTransferFrom(msgSender, receiver, id);

        totalSupply--;

        emit Withdraw(msgSender, receiver, id);

        requireAccountAndVaultStatusCheck(owner);
    }   
}