// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.19;

interface IERC721PriceOracleMock {
    function getQuote(address base, address nft_collection, uint256 id) external view returns (uint256 out);
}
