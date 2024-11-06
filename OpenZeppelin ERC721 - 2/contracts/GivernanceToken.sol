// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceToken is ERC721Enumerable, Ownable {
    // 각 NFT의 투표 권한을 저장하는 매핑
    mapping(uint256 => uint256) public votingPower;

    // 투표 결과를 저장하는 변수
    uint256 public totalFor;
    uint256 public totalAgainst;

    // 토큰 ID 카운터
    uint256 public tokenCounter;

    // 컨트랙트 생성자
    constructor() ERC721("GovernanceVotingToken", "GVT") Ownable(msg.sender) {
        tokenCounter = 0;  // 토큰 카운터 초기화
    }

    // 여러 개의 NFT 발행 및 투표 권한 설정
    function mintNFTs(address recipient, uint256[] memory tokenIds, uint256[] memory powers) public onlyOwner {
        require(tokenIds.length == powers.length, "Token IDs and Powers must match in length");
        
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _mint(recipient, tokenIds[i]);  // NFT 발행
            votingPower[tokenIds[i]] = powers[i];  // 각 토큰에 대한 투표 권한 설정
            tokenCounter++;  // 토큰 카운터 증가
        }
    }

    // 사용자가 각 NFT에 대해 찬성/반대 투표를 할 수 있는 함수
    function vote(uint256[] memory tokenIds, bool[] memory votes) public {
        require(tokenIds.length == votes.length, "Token IDs and votes length must match");

        // 각 NFT의 투표 권한을 확인하고 투표 수행
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
            require(votingPower[tokenId] > 0, "Token has no voting power");

            if (votes[i]) {
                totalFor += votingPower[tokenId];  // 찬성
            } else {
                totalAgainst += votingPower[tokenId];  // 반대
            }

            // 이벤트 발생 (각 NFT의 투표 결과)
            emit Voted(msg.sender, tokenId, votes[i], votingPower[tokenId]);
        }
    }

    // 전체 투표 결과를 반환하는 함수
    function getVoteResult() public view returns (string memory) {
        if (totalFor > totalAgainst) {
            return "For";  // 찬성 결과
        } else if (totalAgainst > totalFor) {
            return "Against";  // 반대 결과
        } else {
            return "Tie";  // 동률
        }
    }

    event Voted(address voter, uint256 tokenId, bool vote, uint256 votingPower);
}