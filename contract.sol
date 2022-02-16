pragma solidity ^0.8.10;

/** 
    Room Reservation Contract

    Twitter: 0xVousk

    Add your room for renting, choose the rent price and for how many days you wish to rent it.

**/


contract Reservation {

    event RoomAdded(address roomOwner, string roomName, uint roomPrice);
    event RoomRented(address roomOwner, string roomName);

    enum RoomStatuses{ Vacant, Occupied }

    struct RoomStruct {
        string roomName;
        uint roomPrice;
        uint forDaysAmount;
        address occupant;
        uint occupiedAt;
        uint occupiedUntil;
        RoomStatuses currentStatuses;
    }

    mapping(address => RoomStruct) Room;

    function addRoom(string memory _roomName, uint _roomPrice, uint _forHowManyDays) public {
        Room[msg.sender].roomName = _roomName;
        Room[msg.sender].roomPrice = _roomPrice;
        Room[msg.sender].forDaysAmount = _forHowManyDays;
        Room[msg.sender].currentStatuses = RoomStatuses.Vacant;
        emit RoomAdded(msg.sender, _roomName, _roomPrice);
    }

    function rentRoom(address _roomOwner) public payable {
        require(Room[_roomOwner].currentStatuses == RoomStatuses.Vacant, "This room is already occupied!");
        require(msg.value == Room[_roomOwner].roomPrice, "Invalid amount.");
        (bool sent, bytes memory data) = _roomOwner.call{value: msg.value}("");
        require(sent, "Could not pay the room owner.");
        Room[_roomOwner].occupant = msg.sender;
        Room[_roomOwner].occupiedAt = block.timestamp;
        Room[_roomOwner].occupiedUntil = block.timestamp + Room[_roomOwner].forDaysAmount * 1 days;
        Room[_roomOwner].currentStatuses = RoomStatuses.Occupied;
        emit RoomRented(_roomOwner, Room[_roomOwner].roomName);
    }

    function getKeysBack() public {
        require(Room[msg.sender].occupant != address(0), "No one is renting your room.");
        require(block.timestamp >= Room[msg.sender].occupiedUntil, "You cannot get your keys until the end of the renting.");
        Room[msg.sender].occupant = address(0);
        Room[msg.sender].occupiedAt = 0;
        Room[msg.sender].occupiedUntil = 0;
        Room[msg.sender].currentStatuses = RoomStatuses.Vacant;
    }


    function getMyRoomInfos() public view returns(
        string memory roomName,
        uint roomPrice,
        uint forDaysAmount,
        address occupant,
        uint occupiedAt,
        uint occupiedUntil,
        RoomStatuses roomStatus) {

        return (Room[msg.sender].roomName,
        Room[msg.sender].roomPrice,
        Room[msg.sender].forDaysAmount,
        Room[msg.sender].occupant,
        Room[msg.sender].occupiedAt,
        Room[msg.sender].occupiedUntil,
        Room[msg.sender].currentStatuses);
    }

    function getRoomFrom(address _address) public view returns(string memory roomName, uint roomPrice, RoomStatuses roomStatus, uint occupiedUntil) {
        return (Room[_address].roomName, Room[_address].roomPrice, Room[_address].currentStatuses, Room[_address].occupiedUntil);
    }


}
