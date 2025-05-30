// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Auth {
    enum Role { VOTER, ADMIN, PHEAD }
    enum Status { PENDING, APPROVED, REJECTED }

    struct User {
        string fullName;
        string profileURL;
        Role role;
        Status status;
        bool isRegistered;
    }

    mapping(address => User) public users;

    address public adminContract;

    modifier onlyAdminContract() {
        require(msg.sender == adminContract, "Only admin contract can call");
        _;
    }

    constructor() {
        // Leave adminContract empty on deployment
    }

    function setAdminContract(address _adminContract) external {
        require(adminContract == address(0), "Admin contract already set");
        require(_adminContract != address(0), "Invalid admin contract address");
        adminContract = _adminContract;
    }

    function register(string memory _fullName, string memory _profileURL) public {
        require(!users[msg.sender].isRegistered, "Already registered");

        users[msg.sender] = User({
            fullName: _fullName,
            profileURL: _profileURL,
            role: Role.VOTER,
            status: Status.PENDING,
            isRegistered: true
        });
    }

    function approveUser(address _user, Role _role) external onlyAdminContract {
        require(users[_user].isRegistered, "User not found");
        users[_user].status = Status.APPROVED;
        users[_user].role = _role;
    }

    function rejectUser(address _user) external onlyAdminContract {
        require(users[_user].isRegistered, "User not found");
        users[_user].status = Status.REJECTED;
    }

    function getUser(address _user) public view returns (
        string memory fullName,
        string memory profileURL,
        Role role,
        Status status,
        bool isRegistered
    ) {
        User memory u = users[_user];
        return (u.fullName, u.profileURL, u.role, u.status, u.isRegistered);
    }
}
