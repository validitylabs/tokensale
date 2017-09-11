/**
 * @title DIP Token Generating Event
 * @dev The Decentralized Insurance Platform Token.
 * @author Christoph Mussenbrock
 * @copyright 2017 Etherisc GmbH
 */

pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/crowdsale/Crowdsale.sol';


contract DipWhitelistedCrowdsale is Crowdsale, Ownable {
  
  using SafeMath for uint256;

  enum state { pendingStart, priorityPass, openedPriorityPass, crowdsale, crowdsaleEnded }

  uint256 public startOpenPpBlock;
  uint256 public startPublicBlock;
  uint256 public minCap;
  uint256 public hardCap1;
  uint256 public hardCap2;

  state public crowdsaleState = state.pendingStart;

  struct ContributorData {
    uint256 priorityPassAllowance;
    uint256 otherAllowance;
    uint256 contributionAmount;
    uint256 tokensIssued;
    uint256 index;
  }

  // list of addresses that can purchase in priorityPass phase
  mapping (address => ContributorData) private contributorList;
  address[] private contributorIndexes;

  event DipTgeStarted(uint256 _blockNumber);
  event OpenPpStarted(uint256 _blockNumber);
  event PublicStarted(uint256 _blockNumber);
  event MinCapReached(uint256 _blockNumber);
  event HardCap1Reached(uint256 _blockNumber);
  event HardCap2Reached(uint256 _blockNumber);
  event DipTgeEnded(uint256 _blockNumber);

  /**
   * Constructor
   * @param _startOpenPpBlock starting block for open PriorityPass phase
   * @param _startPublicBlock starting block for public phase
   * @param _minCap           minimum goal (only info)
   * @param _hardCap1         hardcap for priority phase
   * @param _hardCap2         hardcap overall
   */
  
  function DipWhitelistedCrowdsale(
    uint256 _startOpenPpBlock,
    uint256 _startPublicBlock, 
    uint256 _minCap,
    uint256 _hardCap1, 
    uint256 _hardCap2
    ) 
  {
    startOpenPpBlock = _startOpenPpBlock;
    startPublicBlock = _startPublicBlock;
    minCap = _minCap;
    hardCap1 = _hardCap1;
    hardCap2 = _hardCap2;
  }

  /*
   * @dev Check if address in the list of contributors
   * @param address _contributorAddr    Address to check
   * @return bool _isContributor        True if contributor, false otherwise
   */
  function isContributor(address _contributorAddr)
    public constant returns (bool _isContributor)
  {
    if (contributorIndexes.length == 0 ) {
        return false;
    }
    return (contributorIndexes[contributorList[_contributorAddr].index] == _contributorAddr);
  }

  /*
   * @dev Add to the list of contributors
   * @param address _addr                   Address
   * @param uint256 _priorityPassAllowance  Priority pass allowance
   * @param uint256 _otherAllowance         Other allowance
   * @return uint256 _index                 Contributor's index
   */
  function addContributor(
      address _addr,
      uint256 _priorityPassAllowance,
      uint256 _otherAllowance)
      onlyOwner public returns (uint256 _index)
  {
    require(!isContributor(_addr));

    contributorList[_addr].priorityPassAllowance = _priorityPassAllowance;
    contributorList[_addr].otherAllowance = _otherAllowance;
    contributorList[_addr].index = contributorIndexes.push(_addr) - 1;

    _index = contributorIndexes.length - 1;
  }

  /*
   * @dev Edit contributor data
   * @param address _addr                   Address
   * @param uint256 _priorityPassAllowance  Priority pass allowance
   * @param uint256 _otherAllowance         Other allowance
   * @return bool _success                  True if succeed
   */
  function editContributor(
      address _addr,
      uint256 _priorityPassAllowance,
      uint256 _otherAllowance)
      onlyOwner public returns (bool _success)
  {
    require(isContributor(_addr));

    contributorList[_addr].priorityPassAllowance = _priorityPassAllowance;
    contributorList[_addr].otherAllowance = _otherAllowance;

    _success = true;
  }

  /*
   * @dev Delete contributor
   * @param address _addr   Contributor's address
   */
  function deleteContributor(address _addr)
    onlyOwner public returns (uint256 _index)
  {
      require(isContributor(_addr));

      uint256 contributorToDelete = contributorList[_addr].index;
      address lastKey = contributorIndexes[contributorIndexes.length - 1];

      contributorIndexes[contributorToDelete] = lastKey;
      contributorList[lastKey].index = contributorToDelete;
      contributorIndexes.length--;

      _index = contributorToDelete;
  }

  /**
   * @dev Push contributor data to the contract before the crowdsale so that they are eligible for priorit pass
   * @param address[] _contributorAddresses         List of addresses
   * @param uint256[] _contributorPPAllowances      List of priority pass allowances
   * @param uint256[] _contributorOtherAllowance    List of other allowances
   */
  function editContributors(
      address[] _contributorAddresses,
      uint256[] _contributorPPAllowances,
      uint256[] _contributorOtherAllowance)
      onlyOwner public
  {
    require(
      _contributorAddresses.length == _contributorPPAllowances.length &&
      _contributorAddresses.length == _contributorOtherAllowance.length
    ); // Check if input data is consistent

    for (uint256 cnt = 0; cnt < _contributorAddresses.length; cnt++) {
        if (isContributor(_contributorAddresses[cnt])) {
            editContributor(
                _contributorAddresses[cnt],
                _contributorPPAllowances[cnt],
                _contributorOtherAllowance[cnt]
            );
        } else {
            addContributor(
                _contributorAddresses[cnt],
                _contributorPPAllowances[cnt],
                _contributorOtherAllowance[cnt]
            );
        }
    }
  }

  /*
   * @dev Get contributors count
   * @return uint256 _count     Contributors count
   */
  function getContributorsCount() constant public returns (uint256 _count) {
      _count = contributorIndexes.length;
  }

  /*
   * @dev Get contributor by address
   * @param address _addr   Address
   * @return                Contributor's data
   */
  function getContributor(address _addr) constant public returns (
    uint256 _priorityPassAllowance,
    uint256 _otherAllowance,
    uint256 _contributionAmount,
    uint256 _tokensIssued,
    uint256 _index)
  {
      require(isContributor(_addr));

      return (
          contributorList[_addr].priorityPassAllowance,
          contributorList[_addr].otherAllowance,
          contributorList[_addr].contributionAmount,
          contributorList[_addr].tokensIssued,
          contributorList[_addr].index
      );
  }

  /*
   * @dev Get contributor at specified index
   * @param uint256 _index                  Contributor's index
   * @return address _contributorsAddress   Contributor's address
   */
  function getContributorAtIndex(uint256 _index) constant public returns (address _contributorAddress) {
      _contributorAddress = contributorIndexes[_index];
  }

  /**
   * Calculate the maximum remaining contribution allowed for an address
   * @param  _contributor the address of the contributor
   * @return maxContribution maximum allowed amount in wei
   */
  function calculateMaxContribution(address _contributor) constant returns (uint256) {

    uint256 maxContrib;
    if (crowdsaleState == state.pendingStart) {
      maxContrib = 0;
    } else if (crowdsaleState == state.priorityPass) {
      maxContrib = 
        contributorList[_contributor].priorityPassAllowance +
        contributorList[_contributor].otherAllowance - 
        contributorList[_contributor].contributionAmount;
      if (maxContrib > hardCap1 - weiRaised){
        maxContrib = hardCap1 - weiRaised;
      }
    } else if (crowdsaleState == state.openedPriorityPass) {
      if (contributorList[_contributor].priorityPassAllowance + 
          contributorList[_contributor].otherAllowance > 0) {
        maxContrib = hardCap1 - weiRaised;
      } else {
        maxContrib = 0;
      }
    } else if (crowdsaleState == state.crowdsale) {
      maxContrib = hardCap2 - weiRaised;
    } else {
      maxContrib = 0;
    } 
    return maxContrib;
  }

  /**
   * Set the current state of the crowdsale.
   */
  function setCrowdsaleState() {
    if (weiRaised >= hardCap2 && crowdsaleState != state.crowdsaleEnded) {
      crowdsaleState = state.crowdsaleEnded;
      HardCap2Reached(block.number);
      DipTgeEnded(block.number);
    }

    if (block.number >= startBlock && block.number < startOpenPpBlock) {
      if (crowdsaleState != state.priorityPass) {
        crowdsaleState = state.priorityPass;
        DipTgeStarted(block.number);
      }
    } else if (block.number >= startOpenPpBlock && block.number < startPublicBlock) {
      if (crowdsaleState != state.openedPriorityPass) {
        crowdsaleState = state.openedPriorityPass;
        OpenPpStarted(block.number);
      }
    } else if (block.number >= startPublicBlock && block.number <= endBlock) {
      if (crowdsaleState != state.crowdsale) {                                       
        crowdsaleState = state.crowdsale;
        PublicStarted(block.number);
      }
    } else {
      if (crowdsaleState != state.crowdsaleEnded && block.number > endBlock) {
        crowdsaleState = state.crowdsaleEnded;
        DipTgeEnded(block.number);
      }
    }
  }

  /**
   * The token buying function.
   * @param  _beneficiary  receiver of tokens.
   */
  function buyTokens(address _beneficiary) payable {
    require(_beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 maxContrib = calculateMaxContribution(_beneficiary);
    uint256 refund;

    if (weiAmount > maxContrib) {
      refund = weiAmount.sub(maxContrib);
      weiAmount = maxContrib;
    }

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);
    if (weiRaised > minCap)
      MinCapReached(block.number);

    if (!token.mint(_beneficiary, tokens)) revert();
    TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

    contributorList[_beneficiary].contributionAmount = contributorList[_beneficiary].contributionAmount.add(weiAmount);
    contributorList[_beneficiary].tokensIssued = contributorList[_beneficiary].tokensIssued.add(tokens);

    wallet.transfer(weiAmount);
    if (refund != 0) msg.sender.transfer(refund);
  }


  /**
   * Returns true if a purchase is valid, i.e. there is *some* allowed amount remaining for the contributor
   * @return bool
   */
  function validPurchase() internal constant returns (bool) {
    setCrowdsaleState();
    return super.validPurchase();
  }

}
