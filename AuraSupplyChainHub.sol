// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;

contract AuraSupplyChainHub {
    struct Product {
        address currentOwner;
        address manufacturer;
        uint256 registrationFeeWei;
        string currentStage;
        bool isActive;
        bytes32 itemHash;
    }

    address payable public immutable hubAdmin;
    string public hubDescriptor;
    uint256 public productCounter;
    uint256 public accumulatedFees;
    bool public isHubHalted;

    mapping(address => bool) public verifiedManufacturers;
    mapping(uint256 => Product) public products;

    event ManufacturerAdded(address indexed manufacturer);
    event ProductCanceled(uint256 indexed productId);
    event TreasuryDeposited(address indexed funder, uint256 amount);
    event ReservesDrained(address indexed admin, uint256 amount);
    event FeesGathered(address indexed admin, uint256 amount);
    event HubHaltToggled(bool isHalted);
    event ProductRegistered(uint256 indexed productId, address indexed manufacturer, bytes32 itemHash);
    event ManufacturerRevoked(address indexed manufacturer);
    event OwnershipTransferred(uint256 indexed productId, address indexed previousOwner, address indexed newOwner);
    event StageUpdated(uint256 indexed productId, string newStage);

    modifier onlyAdmin() {
        require(msg.sender == hubAdmin, "AuraSupply: Access denied");
        _;
    }

    modifier whenNotHalted() {
        require(!isHubHalted, "AuraSupply: Hub is halted");
        _;
    }

    constructor() {
        hubAdmin = payable(msg.sender);
        hubDescriptor = "Aura Base Supply Chain Hub v1";
        isHubHalted = false;
        verifiedManufacturers[msg.sender] = true;
    }

    // 1. addVerifiedManufacturer
    function addVerifiedManufacturer(address manufacturer) external onlyAdmin {
        require(!verifiedManufacturers[manufacturer], "AuraSupply: Already verified");
        verifiedManufacturers[manufacturer] = true;
        emit ManufacturerAdded(manufacturer);
    }

    // 2. cancelProductRegistration
    function cancelProductRegistration(uint256 productId) external {
        Product storage p = products[productId];
        require(productId > 0 && productId <= productCounter, "AuraSupply: Invalid ID");
        require(msg.sender == p.manufacturer || msg.sender == hubAdmin, "AuraSupply: Unauthorized");
        require(p.isActive, "AuraSupply: Already inactive");

        p.isActive = false;
        emit ProductCanceled(productId);
    }

    // 3. depositPlatformTreasury
    function depositPlatformTreasury() external payable whenNotHalted {
        require(msg.value > 0, "AuraSupply: Zero deposit");
        accumulatedFees += msg.value;
        emit TreasuryDeposited(msg.sender, msg.value);
    }

    // 4. drainPlatformReserves
    function drainPlatformReserves() external onlyAdmin {
        uint256 balance = address(this).balance;
        require(balance > 0, "AuraSupply: Zero balance");

        accumulatedFees = 0;
        (bool sent, ) = hubAdmin.call{value: balance}("");
        require(sent, "AuraSupply: Sweep failed");

        emit ReservesDrained(hubAdmin, balance);
    }

    // 5. gatherPlatformFees
    function gatherPlatformFees() external onlyAdmin {
        uint256 amount = accumulatedFees;
        require(amount > 0, "AuraSupply: Zero fees");

        accumulatedFees = 0;
        (bool sent, ) = hubAdmin.call{value: amount}("");
        require(sent, "AuraSupply: Harvest failed");

        emit FeesGathered(hubAdmin, amount);
    }

    // 6. haltSupplyHub
    function haltSupplyHub(bool isHalted) external onlyAdmin {
        isHubHalted = isHalted;
        emit HubHaltToggled(isHalted);
    }

    // 7. registerNewProduct
    function registerNewProduct(bytes32 itemHash, string calldata initialStage) external payable whenNotHalted returns (uint256) {
        require(verifiedManufacturers[msg.sender], "AuraSupply: Not a verified manufacturer");
        require(msg.value > 0, "AuraSupply: Registration fee required");

        accumulatedFees += msg.value;
        productCounter++;

        products[productCounter] = Product({
            currentOwner: msg.sender,
            manufacturer: msg.sender,
            registrationFeeWei: msg.value,
            currentStage: initialStage,
            isActive: true,
            itemHash: itemHash
        });

        emit ProductRegistered(productCounter, msg.sender, itemHash);
        emit StageUpdated(productCounter, initialStage);
        return productCounter;
    }

    // 8. revokeManufacturerStatus
    function revokeManufacturerStatus(address manufacturer) external onlyAdmin {
        require(verifiedManufacturers[manufacturer], "AuraSupply: Not verified");
        require(manufacturer != msg.sender, "AuraSupply: Cannot revoke self");
        verifiedManufacturers[manufacturer] = false;
        emit ManufacturerRevoked(manufacturer);
    }

    // 9. transferProductOwnership
    function transferProductOwnership(uint256 productId, address newOwner) external whenNotHalted {
        Product storage p = products[productId];
        require(productId > 0 && productId <= productCounter, "AuraSupply: Invalid ID");
        require(p.isActive, "AuraSupply: Product inactive");
        require(msg.sender == p.currentOwner, "AuraSupply: Not the owner");
        require(newOwner != address(0), "AuraSupply: Zero address transfer");

        p.currentOwner = newOwner;
        emit OwnershipTransferred(productId, msg.sender, newOwner);
    }

    // 10. updateProductStage
    function updateProductStage(uint256 productId, string calldata newStage) external whenNotHalted {
        Product storage p = products[productId];
        require(productId > 0 && productId <= productCounter, "AuraSupply: Invalid ID");
        require(p.isActive, "AuraSupply: Product inactive");
        require(msg.sender == p.currentOwner || msg.sender == p.manufacturer, "AuraSupply: Unauthorized");

        p.currentStage = newStage;
        emit StageUpdated(productId, newStage);
    }
}