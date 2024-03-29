// SPDX-License-Identifier: GPL-3.0
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
pragma solidity 0.8.0;



 
contract Loterry is VRFConsumerBase{
    address payable[] public players;
    address public manager;
      bytes32 internal keyHash;
    uint256 internal fee;
     uint256 public randomResult;
     uint r;
    uint256 public erc20balance;
   
    constructor()
     VRFConsumerBase(0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, 0x01BE23585060835E02B77ef475b0Cc51aA1e0709)
     {
       keyHash=0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
         fee = 0.1 * 10 ** 18;    
     manager=msg.sender;
     players.push(payable(manager));
    }
    fallback()external payable {

    }
    receive() external payable{
    
       require(msg.sender!= manager);
       require(msg.value==0.1 ether);
       players.push(payable(msg.sender));
        
    }
    function getBalance()public view returns(uint){
    return address(this).balance;
    }

    
      function getRandomNumber() public returns (bytes32 requestId) {
        require(msg.sender== manager);
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }
     function fulfillRandomness(bytes32 requestId,uint256 randomness) internal override {
        randomResult=randomness;
        address payable winner;
        winner=players[randomResult%players.length];
        uint managercut=(getBalance()*10)/100;
        uint winnerprize=(getBalance()*90)/100;
        winner.transfer(winnerprize);
        payable(manager).transfer(managercut);
        players=new address payable[](0); 
       
        
    }
    function pickwinner() public{
        require(msg.sender==manager);
        require (players.length>=1);
        getRandomNumber();
      

    }
   

     function withdrawLink(address to, uint amount) external {
       IERC20 token=IERC20(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
        erc20balance=token.balanceOf(address(this));
       require(amount <= erc20balance, "balance is low");
       token.transfer(to, amount*10**18);
     }
}
    

