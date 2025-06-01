// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ElectionContract {
    enum ElectionLevel { STATE, DISTRICT, MANDAL, CONSTITUENCY } // 0,1,2,3
    enum ElectionType { LOK_SABHA, VIDHAN_SABHA, MUNICIPAL, PANCHAYAT, BY_ELECTION } // 0-4
    enum ElectionStatus { UPCOMING, ONGOING, COMPLETED }

    struct Candidate {
        address candidateWallet;
        uint256 voteCount;
        bool isRegistered;
    }

    struct Election {
        string title;
        string purpose;
        uint256 startDate;
        uint256 endDate;
        ElectionType electionType;
        ElectionLevel level;
        uint256 constituencyId;
        ElectionStatus status;
        bool resultDeclared;
        address winner;
        address[] candidateList;
        mapping(address => Candidate) candidates;
        mapping(address => bool) hasVoted;
    }

    address public admin;
    uint256 public electionCount;
    mapping(uint256 => Election) private elections;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call");
        _;
    }

    event ElectionCreated(uint256 indexed electionId, string title);
    event CandidateAdded(uint256 indexed electionId, address candidate);
    event VoteCast(uint256 indexed electionId, address voter, address candidate);
    event ResultDeclared(uint256 indexed electionId, address winner);
    event AdminTransferred(address indexed oldAdmin, address indexed newAdmin);

    constructor() {
        admin = msg.sender;
    }

    // ADDED: Admin management functions
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        address oldAdmin = admin;
        admin = newAdmin;
        emit AdminTransferred(oldAdmin, newAdmin);
    }

    function getAdmin() public view returns (address) {
        return admin;
    }

    function createElection(
        string memory _title,
        string memory _purpose,
        uint256 _startDate,
        uint256 _endDate,
        ElectionType _type,
        ElectionLevel _level,
        uint256 _constituencyId
    ) public onlyAdmin returns (uint256) {
        require(_startDate < _endDate, "Start must be before end");

        electionCount++;
        Election storage e = elections[electionCount];
        e.title = _title;
        e.purpose = _purpose;
        e.startDate = _startDate;
        e.endDate = _endDate;
        e.electionType = _type;
        e.level = _level;
        e.constituencyId = _constituencyId;
        e.status = ElectionStatus.UPCOMING;
        e.resultDeclared = false;

        emit ElectionCreated(electionCount, _title);
        return electionCount;
    }

    function addCandidate(uint256 _electionId, address _candidate) public onlyAdmin {
        Election storage e = elections[_electionId];
        require(!e.candidates[_candidate].isRegistered, "Already registered");

        e.candidates[_candidate] = Candidate(_candidate, 0, true);
        e.candidateList.push(_candidate);

        emit CandidateAdded(_electionId, _candidate);
    }

    function vote(uint256 _electionId, address _candidate) public {
        Election storage e = elections[_electionId];

        require(block.timestamp >= e.startDate && block.timestamp <= e.endDate, "Election not active");
        require(!e.hasVoted[msg.sender], "Already voted");
        require(e.candidates[_candidate].isRegistered, "Invalid candidate");

        e.candidates[_candidate].voteCount += 1;
        e.hasVoted[msg.sender] = true;

        emit VoteCast(_electionId, msg.sender, _candidate);
    }

    function declareResult(uint256 _electionId) public onlyAdmin {
        Election storage e = elections[_electionId];

        require(block.timestamp > e.endDate, "Election not yet ended");
        require(!e.resultDeclared, "Already declared");

        uint256 highestVotes = 0;
        address winnerAddress;

        for (uint i = 0; i < e.candidateList.length; i++) {
            address candidate = e.candidateList[i];
            if (e.candidates[candidate].voteCount > highestVotes) {
                highestVotes = e.candidates[candidate].voteCount;
                winnerAddress = candidate;
            }
        }

        e.resultDeclared = true;
        e.status = ElectionStatus.COMPLETED;
        e.winner = winnerAddress;

        emit ResultDeclared(_electionId, winnerAddress);
    }

    // --- Getter Functions ---

    function getBasicElectionInfo(uint256 _electionId) public view returns (
        string memory title,
        string memory purpose,
        uint256 startDate,
        uint256 endDate,
        ElectionType electionType,
        ElectionLevel level,
        uint256 constituencyId,
        ElectionStatus status,
        bool resultDeclared,
        address winner,
        uint256 candidateCount
    ) {
        Election storage e = elections[_electionId];
        return (
            e.title,
            e.purpose,
            e.startDate,
            e.endDate,
            e.electionType,
            e.level,
            e.constituencyId,
            e.status,
            e.resultDeclared,
            e.winner,
            e.candidateList.length
        );
    }

    function getCandidateByIndex(uint256 _electionId, uint256 index) public view returns (
        address candidateAddress,
        uint256 voteCount,
        bool isRegistered
    ) {
        Election storage e = elections[_electionId];
        require(index < e.candidateList.length, "Invalid candidate index");
        address candidateAddr = e.candidateList[index];
        Candidate storage c = e.candidates[candidateAddr];
        return (candidateAddr, c.voteCount, c.isRegistered);
    }
}