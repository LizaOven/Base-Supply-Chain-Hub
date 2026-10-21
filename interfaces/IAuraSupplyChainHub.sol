// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;
interface IAuraSupplyChainHub {
    function registerNewProduct(bytes32 itemHash, string calldata initialStage) external payable returns (uint256);
    function transferProductOwnership(uint256 productId, address newOwner) external;
}
