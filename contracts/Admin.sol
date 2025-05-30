// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Auth.sol";

contract Admin {
    address public owner;
    Auth public authContract;

    struct Party {
        string name;
        string symbol;
        address leader;
        bool exists;
    }

    mapping(address => Party) public parties;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
        // authContract unset initially
    }

    function setAuthContract(address _authAddress) external onlyOwner {
        require(address(authContract) == address(0), "Auth contract already set");
        require(_authAddress != address(0), "Invalid auth contract address");
        authContract = Auth(_authAddress);
    }

    function approveUser(address _user, Auth.Role _role) external onlyOwner {
        authContract.approveUser(_user, _role);
    }

    function rejectUser(address _user) external onlyOwner {
        authContract.rejectUser(_user);
    }

    function createParty(string memory _name, string memory _symbol, address _leader) external onlyOwner {
        require(!parties[_leader].exists, "Party leader already has a party");
        parties[_leader] = Party({
            name: _name,
            symbol: _symbol,
            leader: _leader,
            exists: true
        });
    }

    function getParty(address _leader) external view returns (
        string memory name,
        string memory symbol,
        address leader,
        bool exists
    ) {
        Party memory p = parties[_leader];
        return (p.name, p.symbol, p.leader, p.exists);
    }
}
