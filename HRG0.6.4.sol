pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;

// to return player[]
contract HorseRacingGame {
    address public manager;

    // 게임 참여자 구조체
    struct player {
        address payable playerAddress;
        uint256 bettingNumber;
    }
    // https://ethereum.stackexchange.com/questions/3373/how-to-clear-large-arrays-without-blowing-the-gas-limit
    // player 구조체 배열
    player[] players;
    uint256 lengthOfPlayer = 0;

    // 솔리디티에서 정수 사용 불가 -> 일단 임시 배당금 배열
    uint256[] public dividend = [3, 2, 1, 1, 0, 0, 0, 0, 0, 0];

    // 경주마들 (index로 생각 = 0번 말 ~ 9번 말)
    uint256[] public racingHorses = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

    constructor() public {
        manager = msg.sender;
    }

    function betting(uint256 _horseNumber) public payable {
        // 배팅최소금액 1이더로 설정, horseNumber = 베팅하고 싶은 말 번호
        require(msg.value >= 1 ether);

        // players.push(player(msg.sender, _horseNumber)); // 배열에 참가자들을 넣는다.
        if (lengthOfPlayer == players.length) {
            // 한칸늘리기
            players.push();
        }
        players[lengthOfPlayer++] = player(msg.sender, _horseNumber);
    }

    // 랜덤으로 horse 등수 정하기 --> random 기반
    function startRacing() public {
        for (uint256 i = 0; i < racingHorses.length; i++) {
            uint256 n =
                i +
                    (uint256(keccak256(abi.encodePacked(now))) %
                        (racingHorses.length - i));
            uint256 temp = racingHorses[n];
            racingHorses[n] = racingHorses[i];
            racingHorses[i] = temp;
        }
    }

    //
    function transferDividend() public restricted {
        uint256 index = 0;

        players[index].playerAddress.transfer(address(this).balance); // 당첨된 배열 인덱스의 계좌로 송금

        lengthOfPlayer = 0; // 게임이 끝나면 배열 초기화
    }

    function getPlayers() public view returns (player[] memory) {
        // 게임 참가자를 보여준다.
        return players;
    }

    modifier restricted() {
        // 게임 진행자를 설정한다.
        require(msg.sender == manager);
        _;
    }
}
