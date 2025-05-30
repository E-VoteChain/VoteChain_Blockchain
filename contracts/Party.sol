// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Party {
    struct Member {
        bool isInvited;
        bool isMember;
    }

    string public partyName;
    string public partySymbol;
    address public partyLeader;

    mapping(address => Member) public members;

    modifier onlyLeader() {
        require(msg.sender == partyLeader, "Only party leader allowed");
        _;
    }

    event MemberInvited(address member);
    event MemberAdded(address member);
    event MemberRejected(address member);

    constructor(string memory _name, string memory _symbol, address _leader) {
        partyName = _name;
        partySymbol = _symbol;
        partyLeader = _leader;
    }

    function inviteMember(address _member) external onlyLeader {
        require(!members[_member].isMember, "Already a member");
        require(!members[_member].isInvited, "Already invited");
        members[_member].isInvited = true;
        emit MemberInvited(_member);
    }

    function acceptInvite() external {
        require(members[msg.sender].isInvited, "No invitation found");
        members[msg.sender].isInvited = false;
        members[msg.sender].isMember = true;
        emit MemberAdded(msg.sender);
    }

    function rejectMember(address _member) external onlyLeader {
        require(members[_member].isInvited || members[_member].isMember, "Not invited or member");
        members[_member].isInvited = false;
        members[_member].isMember = false;
        emit MemberRejected(_member);
    }

    function isMember(address _addr) external view returns (bool) {
        return members[_addr].isMember;
    }
}
