Rock-Paper-Scissors contract.
The smart contract is written in Solidity. It implements the Rock, Paper, Scissors (RPS) game. Two users can play this game, where each player chooses either rock, paper, or scissors, and then reveals their choice to determine the winner.

Contract variables and modifiers:
user1 and user2: Addresses of the two participants in the game.
hash1 and hash2: Hashed values of choices made by user1 and user2.
claimed1 and claimed2: Integer values representing the choices made by the users (1 for rock, 2 for paper, 3 for scissors).
firstRevealTime: Time of when the first user reveals their choice.
checkbalance: Ensures the sender sent at least 5 ether.
isRegistered: Ensures the sender is one of the players.
isNotRegistered: Ensures the sender is not already registered as a player.
bothLocked: Ensures both users have locked in their hashed choices.
bothClaimed: Ensures both users have claimed their choices or enough time has passed since the first reveal.
validChoice: Validates that the input string choice is either 'rock', 'paper', or 'scissors'.

Contract functions:
register(): Allows a user to register as a player by sending at least 5 ether.
lock(string memory choice, string memory randStr): Allows a registered user to lock in their choice along with a random string.
open(string memory choice, string memory randStr): Allows a user to reveal their choice after both have locked.
processRewards(): Processes the result and transfers the ether rewards to the winner or splits it in the case of a tie.
getUser1() and getUser2(): Return the addresses of the two players.
getState(): Returns the current state of the game.




The game process:
1. Registration: players register to participate in the game.
•	Player must send at least 5 ether to the contract.
•	Player must not already be registered.
•	The first player to register becomes user1.
•	The second player to register becomes user2.

2. Locking in Choices: players lock their choices without revealing them to the opponent.
•	Players provide their choice ("rock", "paper", or "scissors") and a random string (randStr) that they enter to the input field. These are hashed together and the resulting hash is stored.
•	user1's choice hash is stored in hash1 and user2's choice hash is stored in hash2.

3. Revealing Choices: players reveal their previously committed choices.
•	Both players must have locked in their choices.
•	Players provide their choice and random string again and they must match the previously stored hash.
•	The choice of the player is identified and stored as an integer (1 for rock, 2 for paper, 3 for scissors) in claimed1 or claimed2.

4. Determining the Winner and Processing Rewards: the contract determines the winner based on the rules of Rock, Paper, Scissors and distributes the rewards.
•	In case of a tie, each player receives back half of their stake.
•	If one player wins, they receive the full combined stake of 10 ether.
•	If a player does not reveal their choice within 120 seconds after the first reveal, they are considered to have lost.
•	The ether is transferred to the winners.
•	The game state is reset and made ready for a new game.
