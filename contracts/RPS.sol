pragma solidity >=0.4.22 <0.9.0;

contract RPS {
    // Rock =0, Paper = 1, Scissors = 2
    address payable user1;
    address payable user2;
    bytes32 hash1;
    bytes32 hash2;
    int claimed1;
    int claimed2;
    uint firstRevealTime;

    modifier checkbalance() {
        require(msg.value >= 5 ether);
        _;
    }
    
    modifier isRegistered() {
        require(msg.sender == user1 || msg.sender == user2);
        _;
    }
    
    modifier isNotRegistered() {
        require(msg.sender != user1 && msg.sender != user2);
        _;
    }
    
    modifier bothLocked() {
        require(hash1 != bytes32(0) && hash2 != bytes32(0));
        _;
    }
    
    modifier bothClaimed() {
        require((claimed1 != 0 && claimed2 != 0) || (block.timestamp - firstRevealTime) >= 120);
        _;
    }
    
    modifier validChoice(string memory choice) {
        require(
            keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("rock")) ||
            keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("paper")) ||
            keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("scissors"))
        );
        _;
    }

    function register() public payable isNotRegistered checkbalance {
        if(user1 == address(0)) {
            user1 = address(uint160(msg.sender));


        } else if(user2 == address(0)) {
            user2 = address(uint160(msg.sender));


        }
    }
    
    function lock(string memory choice, string memory randStr) 
        public 
        isRegistered 
        validChoice(choice) 
        returns (bool) 
    {
        bytes32 tempHash = keccak256(abi.encodePacked(abi.encodePacked(choice), randStr));
        if(msg.sender == user1 && hash1 == bytes32(0)) {
            hash1 = tempHash;
            return true;
        }
        if(msg.sender == user2 && hash2 == bytes32(0)) {
            hash2 = tempHash;
            return true;
        }
        return false;
    }
    
    function open(string memory choice, string memory randStr) 
        public 
        isRegistered 
        bothLocked 
        validChoice(choice) 
        returns (bool) 
    {
        bytes32 tempHash = keccak256(abi.encodePacked(abi.encodePacked(choice), randStr));
        if(msg.sender == user1 && tempHash == hash1) {
            if(keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("rock"))) {
                claimed1 = 1;
            } else if(keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("paper"))) {
                claimed1 = 2;
            } else if(keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("scissors"))) {
                claimed1 = 3;
            }
            if(firstRevealTime == 0) firstRevealTime = block.timestamp;
            return true;
        }
        if(msg.sender == user2 && tempHash == hash2) {
            if(keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("rock"))) {
                claimed2 = 1;
            } else if(keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("paper"))) {
                claimed2 = 2;
            } else if(keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("scissors"))) {
                claimed2 = 3;
            }
            if(firstRevealTime == 0) firstRevealTime = block.timestamp;
            return true;
        }
        return false;
    }

	function processRewards() public bothLocked bothClaimed{
		// In case of no result, send half money to either parties
		if(claimed1==claimed2){
			user1.transfer(4990000000000000000);
			user2.transfer(4990000000000000000);
		}
		// 3 choices in which user 1 wins
		if((claimed1==1 && claimed2==3) || (claimed1==2 && claimed2==1) || (claimed1==3 && claimed2==2) || claimed2==0)
			user1.transfer(9980000000000000000);
		// 3 choices in which user 1 wins
		if((claimed1==3 && claimed2==1) || (claimed1==1 && claimed2==2) || (claimed1==2 && claimed2==3) || claimed1==0)
			user2.transfer(9980000000000000000);
		// Reset all variables
		user1 = address(0);

		user2 = address(0);

		hash1 = bytes32(0);
		hash2 = bytes32(0);
		claimed1 = 0;
		claimed2 = 0;
		firstRevealTime = 0;
	}
	// Function to get user 1
	function getUser1() public view returns (address) {
	  	return user1;
	}
	// Function to get user 2
	function getUser2() public view returns (address) {
	  	return user2;
	}
	// Function to get state of game
	/* States : 			0  	Users have not locked yet
							1  	User 2 has locked, user 1 hasn't
							2  	User 1 has locked, user 2 hasn't
							421	Both users have locked, user1 claimed 'paper', user2 claimed 'rock'
							413	Both users have locked, user1 claimed 'rock', user2 claimed 'scissors'
							402 Both users have locked, user1 hasn't claimed anything yet, user2 claimed 'scissors'
							441 Both users have locked, user1 coulnd't claim (timed-out), user2 claimed 'rock'
	*/
	function getState() public view returns (int) {
	  	if(hash1==bytes32(0) && hash2==bytes32(0))
	  		return 0;
	  	if(hash1==bytes32(0) && hash2!=bytes32(0))
	  		return 1;
	  	if(hash1!=bytes32(0) && hash2==bytes32(0))
	  		return 2;
	  	// Both users have locked at this point of time, return values if claimed
	  	int ans = 400 + (claimed1*10 + claimed2);

	  	// Check the case of a user not able to claim a choice for long
	  	if(firstRevealTime!=0 && (now-firstRevealTime)>=120){
	  		if(claimed1 == 0)
	  			ans = 400 + (40 + claimed2);
	  		if(claimed2 == 0)
	  			ans = 400 + (claimed1*10 + 4);
	  	}

	  	return ans;
	}
}