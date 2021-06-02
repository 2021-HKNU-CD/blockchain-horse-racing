pragma solidity ^0.4.21;

contract HorseRacingGame {
  address public manager;
  address[] public players;

  // 경주마들 (index로 생각 = 0번 말 ~ 9번 말)
  uint[] public racingHorses = [0,1,2,3,4,5,6,7,8,9];

  // 일단 사용 안함
  // uint[] public dividend = [3,2,1];

  // 베팅 금액 저장할 배열
  uint[] public bettingMoney;

  // User가 베팅하는 
  uint[] public userChoiceHorse;
  
  uint public firstHorse;
  uint public secondHorse;
  uint public thirdHorse;

  // 컨트랙트를 Deploy 하는 계정 -> manager
  constructor() public {
    manager = msg.sender;
  }

  function betting(uint _horseNumber) public payable { // 배팅최소금액 1이더로 설정, horseNumber = 베팅하고 싶은 말 번호
    require(msg.value >= 1 ether);
    require(msg.value <= 4 ether);
    
    players.push(msg.sender); // 배열에 사용자들을 넣는다.
    bettingMoney.push(msg.value); // 배열에 사용자들의 베팅 금액을 넣는다.
    userChoiceHorse.push(_horseNumber); // 배열에 사용자들이 선택한 말의 번호를 넣는다. 
  }


  // 랜덤으로 horse 등수 정하기 --> random 기반
  function startRacing() public {
    for (uint256 i = 0; i < racingHorses.length; i++) {
        uint256 n = i + uint256(keccak256(abi.encodePacked(now))) % (racingHorses.length - i);
        uint256 temp = racingHorses[n];
        racingHorses[n] = racingHorses[i];
        racingHorses[i] = temp;
    }
  }

  // 
  function transferDividend() public restricted {
    
    prizeFirst();
    prizeSecond();
    prizeThird();

    players = new address[](0); // 게임이 끝나면 배열 초기화
  }

  function prizeFirst() public {  
    firstHorse = racingHorses[0];
    for(uint i=0; i<players.length; i++) {
      if(userChoiceHorse[i] == firstHorse) {
        players[i].transfer(bettingMoney[i] * 3);
      }
    }
  }

  function prizeSecond() public {  
    secondHorse = racingHorses[1];
    for(uint i=0; i<players.length; i++) {
      if(userChoiceHorse[i] == secondHorse) {
        players[i].transfer(bettingMoney[i] * 2);
      }
    }
  }

  function prizeThird() public {  
    thirdHorse = racingHorses[2];
    for(uint i=0; i<players.length; i++) {
      if(userChoiceHorse[i] == thirdHorse) {
        players[i].transfer(bettingMoney[i]);
      }
    }
  }

  function getPlayers() public view returns (address[]) { // 게임 참가자를 보여준다.
    return players;
  }

  modifier restricted() { // 게임 진행자를 설정한다.
    require(msg.sender == manager);
    _;
  }
}