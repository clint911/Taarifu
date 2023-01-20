// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/* Things that this contract is going to do  
*/ 

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20SnapshotUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/* 
*@dev inheriting contracts from openzeppelin to make our contract even more secure 
*/ 

error Taarifu__TooMuchGas(); 
contract Taarifu is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20SnapshotUpgradeable, AccessControlUpgradeable, PausableUpgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable {
    /* Immutable Varibles */ 
bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
//you can change the gas limit or introduce a mathematical function to calculate later 
uint256 public constant GAS_LIMIT = 1 CelloUsd; 
      /* State Variables */ 
uint256 public s_yesCount; 
uint256 public s_noCount; 
uint256 public s_gasAmount;//simulate estimation on an instance of the poll 
      /* Other Contract Variables */ 
//mapping of voter address to their vote 
mapping(address => bool) public votes; 

      
constructor() {
        _disableInitializers();
    }

    /* change native token to the CelloUsd 
       *extend some of the functionality or just change from eth to Cusd  
    */ 
function initialize() initializer public {
        __ERC20_init("MyToken", "MTK");
        __ERC20Burnable_init();
        __ERC20Snapshot_init();
        __AccessControl_init();
        __Pausable_init();
        __ERC20Permit_init("MyToken");
        __ERC20Votes_init();
                                    
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SNAPSHOT_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

    }
/* What the various states represents  
 * Created -> A Poll has just been created but room for voting has not been allowed 
 *Active -> Room for voting is open 
 *Succeeded -> Poll was created, voting occured 
 *Queued -> Everything went fine awaiting smart contract transaction to get mined 
 *Queued also handles the paused state 
 *Executed -> Poll Occurred, Everything went fine. 
*/ 

enum ContractState { Created, Active, Succeeded, Queued, Executed } 
    //Utilizing snapshots to keep the status of the smart contract before and after a voting transaction for a proposal has occurred 

/* Events */ 
*@dev You can change 2nd @param type to say an enum or struct to accomodate several voting options  
*/ 
event votedEvent(address indexed voter, bool vote);

//voting function 
function vote(bool choice) public {
 //store voter's choice 
 votes[msg.sender] = choice; 

 //emit event to log vote  
 emit votedEvent(msg.sender, choice); 
}

//getting the vote of a particular address --you can set it to private for anonimity or a n enum to allow for some form of anonimity 
function getVote(address voter) public view returns(bool) {
    return votes[voter]; 
}

//Poll evaulation 
function evaluatePoll() public view returns (bool) {
    //intialiazing global vars for use in our functions 
s_yesCount = 0; 
s_noCount = 0; 

//iterate through all votes and count the no of yesVotes and noVotes 
//If statement for a gas limit 
if(gasAmount >= GAS_LIMIT) {
   revert Taarifu__TooMuchGas();  
} for(address voter in votes) {
    if(votes[voter]) {
        s_yesCount++; 
    else {
        s_noCount++;

}                   
    } 
//determine the majority vote 
if(s_yesCount > s_noCount) {
 return true; 
}
else {
 return false; 
}
}
}
//function called when taking a snapshot  of the SC before a voting transaction getting structure 
function snapshot() public onlyRole(SNAPSHOT_ROLE) {
        _snapshot();
    }

//The Contract can be paused in certain circumstances to prevent some shit 
function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

//Unpausing the contract after the issues are dealt with 
function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }
//storing the state of addreses and tokens before the voting transaction 
function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20Upgradeable, ERC20SnapshotUpgradeable)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // The following functions are overrides required by Solidity.

    //storing the state after voting transaction 
function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    /* Replace with token allocation to various addresses or the chosen voting model 
    * whatever the model you use, the token allocation should be done here 
    */ 
function _mint(address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._mint(to, amount);
    }
  /* Replacing with punishment of bad actors model ie slashing their tokens or downlisting * their addresses 
    */ 
function _burn(address account, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._burn(account, amount);
    }
//function to get the majority vote 
function getResults() public pure returns(bool) {

}
}
//states Created, Active, Succeeded, Queued, Executed. 
//TODO: 1) Voting mechanism, this can be implement via the use of a ERC20TOKEN or Erc721 no fungible token ---Disadvantages, you will end up auctioning the voting power to those with more tokens.
//MOC:Proof of Personhood participation 

