// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract GoldMiner is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    struct GamePeriod {
        uint256 seed; // Random number for generating playground data
        uint256 gameCounter; // Number of games in the period
        address[] participants; // Participants during the period
        mapping(address => uint256) points; // Points earned by players during a period
        mapping(address => uint256) lastPlayedTimes; // Last time the player has played a game
        mapping(address => bool) isPlayed; // True if a participant once played
        address[5] awardees; // Address of awardees
        uint256[5] awardAmounts; // Award amounts
        uint256 startTime; // Timestamp of the start of the period
        uint256 endTime; // Timestamp of the end of the period
    }

    struct GamePeriodView {
        uint256 seed;
        uint256 gameCounter;
        address[] participants;
        address[5] awardees;
        uint256[5] awardAmounts;
        uint256 startTime;
        uint256 endTime;
    }

    // Setting variables
    address public withdrawAddress =
        address(0xf753C11e5167247f156D22B0dd6C6333b934835c);
    uint256[5] public awardShare = [29, 24, 19, 14, 9]; // Share rates of award, eg. 29%/24%/19%/14%/9%
    uint256 public price = 0; //5e17; // Price for playing a single game

    // Permanent variables
    address[] public players; // Address of players
    mapping(address => uint256) public accPoints; // Points accumulated by players
    mapping(address => uint256) public accAwards; // Awards accumulated by players
    mapping(address => bool) public playable; // True if address has paid to play
    mapping(address => bool) public isPlayed; // True if address has once played

    GamePeriod[] public periods;
    uint256 private periodIndex; // Index of current period

    event StartPeriod(uint256 periodIndex, uint256 timestamp);
    event EndPeriod(uint256 periodIndex, uint256 timestamp);
    event StartGame(uint256 periodIndex, address player, uint256 timestamp);
    event EndGame(
        uint256 periodIndex,
        address player,
        uint256 point,
        uint256 timestamp
    );

    // Check if enough payment is covered
    modifier paymentCovered() {
        require(msg.value >= price, "Not enough payment");
        _;
    }

    // constructor(address owner) {
    //     transferOwnership(owner);
    // }

    function startPeriod() external onlyOwner {
        if (periods.length > 0) {
            endPeriod(periodIndex);
            periodIndex++;
        }
        GamePeriod storage period = periods.push();
        period.seed = RNG();
        period.startTime = block.timestamp;
        emit StartPeriod(periodIndex, block.timestamp);
    }

    function endPeriod(uint256 index) internal {
        GamePeriod storage period = periods[index];

        // Determine who the winners are
        address[5] memory winners;
        for (uint256 i = 0; i < period.participants.length; i++) {
            for (uint256 j = 0; j < 5; j++) {
                if (
                    winners[j] == address(0) ||
                    (period.points[period.participants[i]] >=
                        period.points[winners[j]] &&
                        period.lastPlayedTimes[period.participants[i]] <
                        period.lastPlayedTimes[winners[j]])
                ) {
                    for (uint256 k = j + 1; k < 5; k++)
                        winners[k] = winners[k - 1];
                    winners[j] = period.participants[j];
                    break;
                }
            }
        }

        // Calculate the award and store the result
        for (uint256 j = 0; j < 5; j++) {
            if (winners[j] == address(0)) break;
            period.awardees[j] = winners[j];
            uint256 amount = (awardShare[j] * period.gameCounter * price) / 100;
            period.awardAmounts[j] = amount;
            (bool awardSuccess, ) = payable(winners[j]).call{value: amount}("");
            require(awardSuccess, "Award transfer failed");
            accAwards[winners[j]] += amount;
        }

        // Withdraw fee
        (bool withdrawSuccess, ) = payable(withdrawAddress).call{
            value: address(this).balance
        }("");
        require(withdrawSuccess, "Fee transfer failed");

        period.endTime = block.timestamp;
        emit EndPeriod(index, block.timestamp);
    }

    // Start game
    function startGame() external payable paymentCovered returns (uint256) {
        playable[_msgSender()] = true;

        // Store temporary variables
        GamePeriod storage period = periods[periodIndex];

        if (period.isPlayed[_msgSender()] == false) {
            period.isPlayed[_msgSender()] = true;
            period.participants.push(_msgSender());
        }
        period.gameCounter++;

        emit StartGame(periodIndex, _msgSender(), block.timestamp);
        return period.seed;
    }

    // End Game
    function endGame(uint256 point) external nonReentrant {
        require(playable[_msgSender()], "bad operation");
        playable[_msgSender()] = false;

        // Store permanent variables
        if (isPlayed[_msgSender()] == false) {
            isPlayed[_msgSender()] = true;
            players.push(_msgSender());
        }
        accPoints[_msgSender()] += point;

        // Store temporary variables
        GamePeriod storage period = periods[periodIndex];
        period.points[_msgSender()] += point;
        period.lastPlayedTimes[_msgSender()] = block.timestamp;

        emit EndGame(periodIndex, _msgSender(), point, block.timestamp);
    }

    // Random number generator
    function RNG() public view returns (uint256) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        return blockValue;
    }

    // Change withdraw address, this function can be called by only owner.
    function setWithdrawAddress(address _withdrawAddress) external onlyOwner {
        withdrawAddress = _withdrawAddress;
    }

    // Change price, this function can be called by only owner.
    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    // Change award share rate, this function can be called by only owner.
    function setAward(
        uint256 first,
        uint256 second,
        uint256 third,
        uint256 fourth,
        uint256 fifth
    ) external onlyOwner {
        awardShare[0] = first;
        awardShare[1] = second;
        awardShare[2] = third;
        awardShare[3] = fourth;
        awardShare[4] = fifth;
    }

    // Get functions
    function getAwardShare() external view returns (uint256[5] memory) {
        return awardShare;
    }

    function getPlayers() external view returns (address[] memory) {
        return players;
    }

    function getPeroidCount() external view returns (uint256) {
        return periods.length;
    }

    function getGamePeriods() external view returns (GamePeriodView[] memory) {
        GamePeriodView[] memory periodViews = new GamePeriodView[](
            periods.length
        );
        for (uint256 i = 0; i < periods.length; i++) {
            periodViews[i] = GamePeriodView({
                seed: periods[i].seed,
                gameCounter: periods[i].gameCounter,
                participants: periods[i].participants,
                awardees: periods[i].awardees,
                awardAmounts: periods[i].awardAmounts,
                startTime: periods[i].startTime,
                endTime: periods[i].endTime
            });
        }
        return periodViews;
    }
}
