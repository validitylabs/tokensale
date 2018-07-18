# Deploy Contracts
RSC Contract is https://etherscan.io/token/0x9b0f6a5a667cb92af0cd15dbe90e764e32f69e77#readContract
DIP TGE Contract is https://etherscan.io/address/0x00391d08B3E68E476a774aDA379258264EB74485
DIP Token Contract is https://etherscan.io/token/0xc719d010b63e5bbf2c0551872cd5316ed26acd83
RSC TotalSupply is 319810709968 (https://etherscan.io/token/0x9b0f6a5a667cb92af0cd15dbe90e764e32f69e77#readContract)

# Specs of RSCConversion.sol
* RSC Holders need to be whitelisted. Whitelisted means “allowance > 0” in the contributorData mapping in the TGE Contract.
* RSC Holders can ask for whitelisting with Bonus + Lockup 1 year.
* RSC Holders convert their RSC in four steps:
  * Registering in the TGE Registration process (we keep it open after TGE)
  * Wait until address is whitelisted, check data
  * Send “approve” Transaction to RSC Token Contract, beneficiary = Conversion Contract
  * Send “convert” Transaction to RSC Conversion Contract.
* Conversion Rate is 10/32. => 10 DIP Tokens for 32 RSC Tokens.
* If RSC Holder receivers DIP_Amount tokens and Bonus > 0, Bonus tokens are calculated as DIP_Amount * 100 / Bonus and added to DIP_Amount.
* Converted RSC Tokens are burned = transferred to address “0x0” DIP_Pool
* DIP Tokens are kept in a separate wallet which has to be funded with enough DIP Tokens before the conversion starts.
* This wallet will “approve” the conversion contract to transfer the required number of tokens.
* In emergency, Conversion can be stopped by revoking this approval.
* Unused bonus tokens can be reclaimed by foundation.
* Tokens accidentally sent to RSCConversion Contract can be salvaged via a salvageTokens function which can be called by owner.

# Written Test Cases (not developed currently)
* It should be possible to create conversion contract.
* It should not be possible to convert RSC tokens before DIP_Pool is funded with DIP Tokens.
* It should not be possible to convert RSC tokens if DIP_Pool has not been funded sufficiently
* It should not be possible to convert RSC tokens if DIP_Pool has not given approval to transfer DIP Tokens.
* It should not be possible to convert RSC tokens if RSC Token Holder is not whitelisted.
* It should not be possible to convert RSC tokens if allowance = 0 for a whitelisted RSC Token holder.
* It should not be possible to convert RSC tokens if RSC Token Holder has not approved conversion contract to transfer tokens.
* It should not be possible to convert RSC tokens if RSC Token Holder has not sufficient RSC Tokens.
* It should not be possible to convert RSC tokens if bonus > 0 and lockupPeriod != 1
* It should be possible to convert RSC Tokens if:
  * DIP_Pool has sufficient DIP tokens
  * DIP_Pool has approved conversion contract to transfer tokens
  * RSC Token Holder is whitelisted and allowance > 0
  * RSC Token Holder has approved conversion contract to transfer tokens
* It should calculate number of converted DIP Tokens correctly (10/32)
* It should calculate bonus correctly (for bonus = 4 and bonus = 10)
* It should send converted RSC Tokens to 0x0
* It should lock DIP Tokens with bonus.
* Test coverage should be 100%.
* It should be possible to salvage Tokens sent to contract by accident.


## Source:
* https://docs.google.com/document/d/1ny0HWbsPdqjSOmfxIKCI3RLYSoKl9VU5bbqwTgE6ciQ/edit?ts=5b4ef663#
