/*
Allows for continuous voting on proposals.
Voters must be enabled by the chairperson.
Voters may be disabled by the chairperson. Disabling a voter also removes their vote.
Anyone may submit a proposal.
Anyone may query which proposal is leading with the most votes.
*/
pragma solidity ^0.4.8;

contract Voting{

    modifier restricted() {
        if (msg.sender == chairperson) _;
    }

    address public chairperson;
    Proposal[] public proposals;
    mapping(address => Voter) public voters;

    struct Voter {
        bool canVote;
        uint vote;   // index of the voted proposal
    }
    struct Proposal {
        bytes32 name;
        bytes32 description;
        uint voteCount;
    }

    function Voting() {
        chairperson = msg.sender;
        //use up index 0 with dummy proposal for non voters
        proposals.push(Proposal({
                name: "00000000000000000000000000000000",
                description: "00000000000000000000000000000000",
                voteCount: 0
            }));
    }
    function EnableVoter(address voter) restricted {        
        voters[voter].canVote = true;
    }
    function DisableVoter(address voter) restricted {        
        voters[voter].canVote = false;
        proposals[voters[voter].vote].voteCount--;
        voters[voter].vote = 0;
        proposals[voters[voter].vote].voteCount++;
    }
    function AddProposals(bytes32[] proposalNames, bytes32[] proposalDescriptions) {
        if(proposalNames.length != proposalDescriptions.length)
            throw;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                description: proposalDescriptions[i],
                voteCount: 0
            }));
        }
    }
    //Setting to 0 means no vote
    function SetVote(uint proposalIndex) {
        if(voters[msg.sender].canVote == true) {
            proposals[voters[msg.sender].vote].voteCount--;
            voters[msg.sender].vote = proposalIndex;
            proposals[voters[msg.sender].vote].voteCount++;
        }
    }
    
    function GetWinningProposal() constant returns (uint winningProposal){
        if(proposals.length > 1) {

            uint winner = 0;
            uint voteCount = 0;
            for (uint i = 1; i < proposals.length; i++) {
                if(proposals[i].voteCount > voteCount) {
                    winner = i;
                    voteCount = proposals[i].voteCount;
                }
            }
            return winner;
        } else {
            throw;
        }

    }
}