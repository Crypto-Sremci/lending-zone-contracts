// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.19;

import "openzeppelin/interfaces/IERC4626.sol";
import "../../ERC20/ERC20CollateralWrapper.sol";
import "forge-std/console.sol";
import {IERC721PriceOracleMock} from "./IERC721PriceOracleMock.sol";

contract ERC721PriceOracleMock is IERC721PriceOracleMock{

    // base asset => nft collection => nft id => amount of base asset
    mapping(address => mapping(address => mapping(uint256 => uint256))) internal prices;

    function name() external pure returns (string memory) {
        return "PriceOracleMock";
    }

    function setPrice(address base, address nft_collection, uint256 id, uint256 priceValue) external {
        console.log("Setting price: ", priceValue);
        prices[base][nft_collection][id] = priceValue;
    }

    function getQuote(address base, address nft_collection, uint256 id) external view returns (uint256 out) {
        uint256 price;
        (base, nft_collection, id, price) = _resolveOracle(base, nft_collection, id);
        console.log("Price: ", price);
        // out = price / 10 ** ERC20(base).decimals();
        out = price;
    }

    function getQuotes(address base, address nft_collection, uint256 id) external view returns (uint256 bidOut, uint256 askOut) {
        uint256 price;
        (base, nft_collection, id, price) = _resolveOracle(base, nft_collection, id);

        bidOut = price; /// 10 ** ERC20(base).decimals();

        askOut = bidOut;
    }

    function _resolveOracle(
        address base,
        address nft_collection,
        uint256 id
    ) internal view returns (address, address, uint256, uint256) {
        // 1. Check if base/quote is configured.
        uint256 price = prices[base][nft_collection][id];
        console.log("Price: ", price);
        return (base, nft_collection, id, price);
    }
}
