pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
//
// Orion Vault OVM security token
//
// For details, please visit: https://orionvault.com
//
// written by Alex Kampa - ak@sikoba.com
//
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
//
// SafeMath
//
// ----------------------------------------------------------------------------

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

}


// ----------------------------------------------------------------------------
//
// DateUtilities
//
// borrowed from https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/master/contracts/BokkyPooBahsDateTimeLibrary.sol
//
// ----------------------------------------------------------------------------

library DateUtilities {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    int constant OFFSET19700101 = 2440588;

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    
}

// ----------------------------------------------------------------------------
//
// Owned
//
// ----------------------------------------------------------------------------

contract Owned {

    address public owner;
    address public newOwner;

    mapping(address => bool) public isAdmin;

    event OwnershipTransferProposed(address indexed _from, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);
    event AdminChange(address indexed _admin, bool _status);

    modifier onlyOwner {require(msg.sender == owner); _;}
    modifier onlyAdmin {require(isAdmin[msg.sender]); _;}

    constructor() public {
        owner = msg.sender;
        isAdmin[owner] = true;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0x0));
        emit OwnershipTransferProposed(owner, _newOwner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function addAdmin(address _a) public onlyOwner {
        require(isAdmin[_a] == false);
        isAdmin[_a] = true;
        emit AdminChange(_a, true);
    }

    function removeAdmin(address _a) public onlyOwner {
        require(isAdmin[_a] == true);
        isAdmin[_a] = false;
        emit AdminChange(_a, false);
    }

}


// ----------------------------------------------------------------------------
//
// Wallet
//
// ----------------------------------------------------------------------------

contract Wallet is Owned {

    address public wallet;

    event WalletUpdated(address newWallet);

    constructor() public {
        wallet = owner;
    }

    function setWallet(address _wallet) public onlyOwner {
        require(_wallet != address(0x0));
        wallet = _wallet;
        emit WalletUpdated(_wallet);
    }

}


// ----------------------------------------------------------------------------
//
// ERC20Interface
//
// ----------------------------------------------------------------------------

contract ERC20Interface {

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    function totalSupply() public view returns (uint);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);

}


// ----------------------------------------------------------------------------
//
// ERC Token Standard #20
//
// ----------------------------------------------------------------------------

contract ERC20Token is ERC20Interface, Owned {

    using SafeMath for uint;

    uint public tokensIssuedTotal;
    mapping(address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;

    function totalSupply() public view returns (uint) {
        return tokensIssuedTotal;
    }

    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }

    function transfer(address _to, uint _amount) public returns (bool) {
        require(_to != 0x0);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint _amount) public returns (bool) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) public returns (bool) {
        require(_to != 0x0);
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint) {
        return allowed[_owner][_spender];
    }

}


// ----------------------------------------------------------------------------
//
// Orion Vault security token
//
// ----------------------------------------------------------------------------

contract OrionVaultSecurityToken is ERC20Token, Wallet {

    using DateUtilities for uint;

    // Basic token data

    string public constant name = "Orion Vault Security Token";
    string public constant symbol = "OVM";
    uint8 public constant decimals = 0;

    // Number of possible tokens in existence

    uint public maxTokenSupply = 10000000;

    // tradeable tokens

    bool public tokensTradeable;
    uint public constant DATE_TRADEABLE_LIMIT = 1546300800; // 01-JAN-2019 00:00:00

    // voting
    
    uint public constant TEAM_VESTING_AMOUNT = 375000;
    uint public teamUnclaimedTokens = 1500000;
    
    uint public constant NEGATIVE_VOTE_THRESHOLD = 25;

    mapping(uint => mapping (address => int8)) vote;
    mapping(uint => uint) votesAgainst;
    mapping(uint => uint) votesTotal;
    mapping(uint => uint) tokenTotal;
    mapping(uint => uint) voteResult;
    mapping(uint => bool) claimedTeam;

    // Dividend
    
    uint public dividendTotal;
    uint public dividendResidue;
    mapping(address => uint) public dividendTracker;

    // exchange for equity variable
    
    bool public isExchangeOpen;

    // Events ---------------------------------------------

    event Dividend(uint _wei, uint _oldResidue, uint _availableToDistribute, uint _newResidue, uint _dividendPerToken, uint _dividendTotal, uint _tokensIssuedTotal);
    event DividendClaimed(address _account, uint _payout);
    event Vote(uint _voteNr, address _account, int8 _before, int8 _after);
    event VoteResult(uint _voteNr, int8 _result, uint _tokens);
    event TeamTokensIssued(address _account, uint _newTeamTokens);
    event ChangedMaxTokenSupply(uint _maxTokenSupply);
    event TokensMinted(address _account, uint _tokens);
    event TokenExchangeRequested(address _account, uint _tokens);
    
    // now alias ------------------------------------------
  
    function atNow() internal view returns (uint) {
        return now;
    }

    // Dividend -------------------------------------------
    
    function payDividend() public onlyOwner payable {
      uint oldDividendResidue = dividendResidue;
      uint availableToDistribute = dividendResidue.add(msg.value);
      uint dividendPerToken = availableToDistribute / tokensIssuedTotal;
      dividendResidue = availableToDistribute - dividendPerToken.mul(tokensIssuedTotal);
      dividendTotal = dividendTotal.add(dividendPerToken);
      emit Dividend(msg.value, oldDividendResidue, availableToDistribute, dividendResidue, dividendPerToken, dividendTotal, tokensIssuedTotal);
    }
    
    function claimDividend(address _account) public {
      if (balances[_account] > 0 && dividendTracker[_account] < dividendTotal) {
          uint payout = (dividendTotal - dividendTracker[_account]).mul(balances[_account]);
          dividendTracker[_account] = dividendTotal;
          _account.transfer(payout);
          emit DividendClaimed(_account, payout);
      }
    }
    
    function claimDividend(address[] _addresses) public {
        for (uint i; i < _addresses.length; i++) {
            claimDividend(_addresses[i]);
        }
    }
    
    // Voting ---------------------------------------------
    
    function getVoteNr() public view returns(uint voteNr) {
        //
        // if voting is open, returns the current voting number
        // otherwise returns 0
        //
        if (teamUnclaimedTokens == 0) return 0;
        (uint year, uint month, uint day) = DateUtilities.timestampToDate(atNow());
        if (year >= 2020 && month == 6) {
            voteNr = 2*(year - 2019);
        } else if (year >= 2019 && month == 12) {
            voteNr = 1 + 2*(year - 2019);
        } else {
            return 0;
        }
    }
    
    function isVotingOpen() public view returns(bool) {
      if (getVoteNr() > 0) return true;
      return false;
    }
    
    function getLastVoteNr() public view returns(uint lastVoteNr) {
      (uint year, uint month, uint day) = DateUtilities.timestampToDate(atNow());
      if (year < 2020) return 0;
      if (month <= 6) {
          lastVoteNr = 1 + 2*(year - 2020);
      } else {
          lastVoteNr = 2*(year - 2019);
      }
    }
    
    function castVoteFor() public {
        uint voteNr = getVoteNr();
        require(voteNr > 0);
        tokenTotal[voteNr] = tokensIssuedTotal;
        if (vote[voteNr][msg.sender] == 0) {
            // casting new positive vote
            vote[voteNr][msg.sender] = 1;
            votesTotal[voteNr] = votesTotal[voteNr].add(balances[msg.sender]);
        } else if (vote[voteNr][msg.sender] == -1) {
            // switching from negative to positive vote
            vote[voteNr][msg.sender] = 1;
            votesAgainst[voteNr] = votesAgainst[voteNr].sub(balances[msg.sender]);
        }
        // NB: nothing to do if the vote was already "for"
    }

    function castVoteAgainst() public {
        uint voteNr = getVoteNr();
        require(voteNr > 0);
        tokenTotal[voteNr] = tokensIssuedTotal;
        if (vote[voteNr][msg.sender] == 0) {
            // casting new negative vote
            vote[voteNr][msg.sender] = -1;
            votesAgainst[voteNr] = votesAgainst[voteNr].add(balances[msg.sender]);
            votesTotal[voteNr] = votesTotal[voteNr].add(balances[msg.sender]);
            emit Vote(voteNr, msg.sender, 0, -1);
        } else if (vote[voteNr][msg.sender] == 1) {
            // switching from positive to negative vote
            vote[voteNr][msg.sender] = -1;
            votesAgainst[voteNr] = votesAgainst[voteNr].add(balances[msg.sender]);
            emit Vote(voteNr, msg.sender, 1, -1);
        }
        // NB: nothing to do if the vote was already "against"
    }
    
    function processVote(uint voteNr) public {
        require(voteNr <= getLastVoteNr());
        require(voteResult[voteNr] == 0);
        if (voteNr > 1) require(voteResult[voteNr - 1] != 0);
        //
        uint percentageAgainst = votesAgainst[voteNr].mul(100) / tokenTotal[voteNr];
        if (percentageAgainst >= NEGATIVE_VOTE_THRESHOLD) {
            voteResult[voteNr] = 2;
            emit VoteResult(voteNr, 2, 0);
        } else {
            voteResult[voteNr] = 1;
            uint newTeamTokens = getTeamTokenAmount();
            if (newTeamTokens > 0) {
                claimDividend(owner);
                balances[owner] = balances[owner].add(newTeamTokens);
                tokensIssuedTotal = tokensIssuedTotal.add(newTeamTokens);
                emit Transfer(0x0, owner, newTeamTokens);
                emit TeamTokensIssued(owner, newTeamTokens);
            }
            emit VoteResult(voteNr, 1, newTeamTokens);
        }
    }
    
    function getTeamTokenAmount() internal returns(uint tokens) {
        if (teamUnclaimedTokens == 0) return 0;
        if (TEAM_VESTING_AMOUNT <= teamUnclaimedTokens) {
            teamUnclaimedTokens = teamUnclaimedTokens - TEAM_VESTING_AMOUNT;
            return TEAM_VESTING_AMOUNT;
        } else {
            tokens = teamUnclaimedTokens;
            teamUnclaimedTokens = 0;
        }
    }
    
    function adjustVotes(address _from, address _to, uint _amount) internal {
      if (!isVotingOpen()) return;
      uint voteNr = getVoteNr();
      if (vote[voteNr][_from] == vote[voteNr][_from]) return;
      //
    
    }
    
    // Minting --------------------------------------------
    
    function ownerChangeMaxTokenSupply(uint _tokens) external onlyOwner {
      require(_tokens <= tokensIssuedTotal.add(teamUnclaimedTokens));
      maxTokenSupply = _tokens;
      emit ChangedMaxTokenSupply(maxTokenSupply);
    }
    
    function mintTokens(address _account, uint _tokens) external onlyOwner {
        require(_tokens <= availableToMint());
        require(_tokens > 0);
        require(_account != 0x0);
        if (balances[_account] > 0) claimDividend(_account);
        balances[_account] = balances[_account].add(_tokens);
        tokensIssuedTotal = tokensIssuedTotal.add(_tokens);
        emit  Transfer(0x0, _account, _tokens);
        emit TokensMinted(_account, _tokens);
    }
    
    function availableToMint() public view returns(uint) {
      return maxTokenSupply.sub(tokensIssuedTotal).sub(teamUnclaimedTokens);
    }

    // Basic Functions ------------------------------------

    constructor() public {}

    function () public {
    }

    function makeTradeable() public {
        require(msg.sender == owner || atNow() > DATE_TRADEABLE_LIMIT);
        tokensTradeable = true;
    }

    // Exchange with equity
    
    function ownerExchangeOpen() public onlyOwner {
        isExchangeOpen = true;
    }
    
    function ownerExchangeClose() public onlyOwner {
        isExchangeOpen = false;
    }
    
    function exchangeForEquity(uint _tokens) public {
        require(isExchangeOpen);
        require(_tokens > 0 && _tokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_tokens);
        tokensIssuedTotal = tokensIssuedTotal.sub(_tokens);
        emit TokenExchangeRequested(msg.sender, _tokens);
    }
    
    // ERC20 functions -------------------

    /* Transfer out any accidentally sent ERC20 tokens */

    function transferAnyERC20Token(address _token_address, uint _amount) public onlyOwner returns (bool success) {
        return ERC20Interface(_token_address).transfer(owner, _amount);
    }

    /* To do before any transfers */
    
    function beforeTransfer(address _from, address _to, uint _amount) internal {
        if (balances[_from] > 0) claimDividend(_from);
        if (balances[_to] > 0) claimDividend(_to);
        if (isVotingOpen()) adjustVotes(_from, _to, _amount);
    }

    /* Override "transfer" */

    function transfer(address _to, uint _amount) public returns (bool success) {
        require(tokensTradeable);
        beforeTransfer(msg.sender, _to, _amount);
        return super.transfer(_to, _amount);
    }

    /* Override "transferFrom" */

    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        require(tokensTradeable);
        beforeTransfer(_from, _to, _amount);
        return super.transferFrom(_from, _to, _amount);
    }

    /* Multiple token transfers from one address to save gas */

    function transferMultiple(address[] _addresses, uint[] _amounts) external {
        require(_addresses.length == _amounts.length);
        for (uint i; i < _addresses.length; i++) {
            transfer(_addresses[i], _amounts[i]);
        }

    }

}