contract OrionVaultSecurityTokenTest is OrionVaultSecurityToken {

    /*

    Introduces function setTestTime(uint)
    
    Overrides function atNow() to return testTime instead of now()

    */

    uint public testTime = 1;
    
    // Events ---------------------------

    event SetTestTime(uint _now);

    // Functions ------------------------

    constructor() public {}

    function atNow() public view returns (uint) {
        return testTime;
    }

    function setTestTime(uint _t) public onlyOwner {
        testTime = _t;
        emit SetTestTime(_t);
    }

}