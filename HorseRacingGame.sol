pragma solidity ^0.4.21;

contract HorseRacingGame {
  address public manager;
  
  // 게임 참여자 구조체
  struct player {
    address playerAddress;
    uint bettingNumber;
  }

  // 솔리디티에서 정수 사용 불가 -> 일단 임시 배당금 배열
  uint[] public dividend = [3,2,1,1,0,0,0,0,0,0];
  
  // player 구조체 배열
  player[] public players; 
  
  // 경주마들 (index로 생각 = 0번 말 ~ 9번 말)
  uint[] public racingHorses = [0,1,2,3,4,5,6,7,8,9];


  constructor() public {
    admin = msg.sender;
  }

  function betting(uint _horseNumber) public payable { // 배팅최소금액 1이더로 설정, horseNumber = 베팅하고 싶은 말 번호
    require(msg.value >= 1 ether);

    players.push(msg.sender, _horseNumber); // 배열에 참가자들을 넣는다.
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

    uint index = 0;

    players[index].transfer(address(this).balance); // 당첨된 배열 인덱스의 계좌로 송금

    players = new address[](0); // 게임이 끝나면 배열 초기화
  }


  function getPlayers() public view returns (address[]) { // 게임 참가자를 보여준다.
    return players;
  }

  modifier restricted() { // 게임 진행자를 설정한다.
    require(msg.sender == manager);
    _;
  }
}


  // 사실 상 안쓰는 코드
  // function random() private view returns (uint) {  // random값을 뽑아준다.
  //   return uint(keccak256(abi.encodePacked(block.difficulty, now, players)));
  // }
  