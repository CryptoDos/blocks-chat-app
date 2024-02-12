// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract ChatApp {
    struct user{
        string name;
        friend[] friendList;
    }

    struct friend{
        address pubkey;
        string name;
    }

    struct message {
        address sender;
        uint256 timestamp;
        string msg;
    }

    struct AllUsers {
        string name;
        address accountAddress;
    }

    AllUsers[] getAllUsers;

    mapping(address => user) userList;
    mapping(bytes32=> message[]) allMessages;

    //check user exist
    function checkUserExist(address pubKey) public view returns(bool){
        return bytes(userList[pubKey].name).length > 0;
    }


    //create account 
    function createAccount(string calldata name) external{
        require(checkUserExist(msg.sender) == false, "Username already exists!");
        require(bytes(name).length > 0, "Username is required!");
        userList[msg.sender].name = name; 
        getAllUsers.push(AllUsers(name, msg.sender));
    }

    //get username
    function getUsername(address pubkey) external view returns(string memory)
    {
        require(checkUserExist(pubkey), "User is not registered");
        return userList[pubkey].name;
    }

    // add friend
    function addFriend(address friend_key, string calldata name) external{
        //validations
        require(checkUserExist(msg.sender), "Create an account first");
        require(checkUserExist(friend_key), "User doesnot exist!");
        require(msg.sender == friend_key, "User cannot add themselves as friends");
        require(checkAlreadyFriends(msg.sender, friend_key) == false, "these users are already friends");

        _addFriend(msg.sender, friend_key, name);
        _addFriend(friend_key, msg.sender, userList[msg.sender].name);

    }

    //check already friends
    function checkAlreadyFriends(address pubKey1, address pubKey2) internal view returns(bool){
        if(userList[pubKey1].friendList.length > userList[pubKey2].friendList.length){
            address temp = pubKey1;
            pubKey1= pubKey2;
            pubKey2= temp;
        }

        for(uint256 i=0; i < userList[pubKey1].friendList.length; i++){
            if(userList[pubKey1].friendList[i].pubkey == pubKey2) return true;
        }
        return false;
    }

    // add freind internal function
    function _addFriend(address me, address friend_key, string memory name) internal{
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }


    //get friend list
    function getUserFriendList() external view returns(friend[] memory){
        return userList[msg.sender].friendList;
    }

    // get chat code
    function _getChatCode(address pubkey1, address pubkey2) internal pure returns(bytes32){
        if(pubkey1 < pubkey2)
        {
            return keccak256(abi.encodePacked(pubkey1, pubkey2 ));
        }else return keccak256(abi.encodePacked(pubkey2, pubkey1));
    }

    function sendMessage(address friend_key, string calldata  _msg ) external  {
        require(checkUserExist(msg.sender), "Create an account first");
        require(checkUserExist(friend_key), "User doesnot exist!");
        require(checkAlreadyFriends(msg.sender, friend_key) , "You are not friend with the given user");

        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);
    }

    function readMessage(address friend_key) external view returns(message[] memory){
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatCode];
    }

    function getAllAppUser() public view returns(AllUsers[] memory){
        return getAllUsers;
    }

}