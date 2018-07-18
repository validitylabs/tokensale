/**
 * @title RSC Conversion Contract
 * @dev The Decentralized Insurance Platform Token.
 * @author Christoph Mussenbrock
 * @copyright 2017 Etherisc GmbH
 */

pragma solidity 0.4.24;

import "../token/DipToken.sol";
import "../tokensale/DipTge.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/token/ERC20.sol";


contract RSCConversion is Ownable {

  using SafeMath for *;

  DipToken DIP;
  DipTge DIP_TGE;
  ERC20 RSC;
  address DIP_Pool;

  event Conversion(uint256 _rscAmount, uint256 _dipAmount, uint256 _bonus);

  // does not check for address 0x0 - is possible to deploy address 0x0?
  constructor (
      address _dipToken,
      address _dipTge,
      address _rscToken,
      address _dipPool) public {
    DIP = DipToken(_dipToken);
    DIP_TGE = DipTge(_dipTge);
    RSC = ERC20(_rscToken);
    DIP_Pool = _dipPool;
  }

  function convert(
    uint256 _rscAmount
  ) public {

    uint256 allowance;
    uint256 bonus;
    uint256 lockupPeriod;
    uint256 dipAmount;

    (allowance, /* contributionAmount */, /* tokensIssued */, /* airDrop */, bonus, lockupPeriod) =
      DIP_TGE.contributorList(msg.sender);

    // allowance amount is NOT factored into any math - curious on the allowance purpose?
    require(allowance > 0);

    // msg.sender requires an allowance through RSC token contract for this contract
    require(RSC.transferFrom(msg.sender, DIP_Pool, _rscAmount));

    // conversion factor 10:32 ratio as listed in the spec document
    dipAmount = _rscAmount.mul(10).div(32);

    // bonus calculation - requires someone with a bonus amount to have lockupPeriod == 1 else will revert the tx
    if (bonus > 0) {
      assert(lockupPeriod == 1);
      dipAmount = dipAmount.add(dipAmount.mul(100).div(bonus));
    }

    // DIP Pool account requires an allowance be made for this contract through  the DIP token contract
    require(DIP.transferFrom(DIP_Pool, msg.sender, dipAmount));
    emit Conversion(_rscAmount, dipAmount, bonus);
  }

}
