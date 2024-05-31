// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import "openzeppelin/interfaces/IERC4626.sol";
import "../../ERC20/ERC20CollateralWrapper.sol";

contract ERC721PriceOracleMock {

    // base asset => nft collection => nft id => amount of base asset
    mapping(address => mapping(address => mapping(uint256 => uint256))) internal prices;

    function name() external pure returns (string memory) {
        return "PriceOracleMock";
    }

    function setPrice(address base, address nft_collection, uint256 id, uint256 priceValue) external {
        prices[base][nft_collection][id] = priceValue;
    }

    function getQuote(address base, address nft_collection, uint256 id) external view returns (uint256 out) {
        uint256 price;
        (base, nft_collection, id, price) = _resolveOracle(base, nft_collection, id);

        out = price / 10 ** ERC20(base).decimals();
    }

    function getQuotes(address base, address nft_collection, uint256 id) external view returns (uint256 bidOut, uint256 askOut) {
        uint256 price;
        (base, nft_collection, id, price) = _resolveOracle(base, nft_collection, id);

        bidOut = price / 10 ** ERC20(base).decimals();

        askOut = bidOut;
    }

    function _resolveOracle(
        address base,
        address nft_collection,
        uint256 id
    ) internal view returns (address, address, uint256, uint256) {
        // 1. Check if base/quote is configured.
        uint256 price = prices[base][nft_collection][id];
        return (base, nft_collection, id, price);
    }
}
