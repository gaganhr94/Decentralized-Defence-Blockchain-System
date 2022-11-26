pragma solidity ^0.6.0;


contract Supply_Chain
{
    uint public _p_id =0; // id for the subparts 
    uint private _u_id =0; // user id - login purposes 
    uint private _t_id=0; // for tracking purpose

    struct track_product 
    {
        uint _product_id;
        uint _owner_id;
        address _product_owner;
        uint _timeStamp;
    }
    mapping(uint => track_product) public tracks;
    
    struct product {
        string _product_name;
        uint _product_cost;
        uint _comp_id;
        string _product_specs;
        string _product_review;
        address _product_owner;
        uint _manufacture_date;

        //Storing the buyers and sellers
        uint[] sell;
        uint[] buy;
    }
    
    mapping(uint => product) public products;
    
    struct participant {
        string _userName;
        string _passWord;
        string _cin;
        address _address;
        string _userType;
        uint rating;
    }
    mapping(uint => participant) public participants;

    
    uint private prevtrack=0;

    uint private transfercount=0;

    string private Owner_ID; 
    string private W_Name;
    uint Cost;
    string public spec;
    string public Weapon_Type;
    string public Product_ID;
    string public Owner;

    uint public access=0; // 1-Military 2- Judiciary 0-Reset
    

    string public RFID;

    address private owner_address;

    //For new military equipment
    constructor( string memory name, string memory own_id,uint p_cost ,string memory p_specs,string memory weapontype, string memory prod_id) public
    {
        owner_address=msg.sender;
        W_Name=name;
        Weapon_Type=weapontype;
        Product_ID=prod_id;
        Cost=p_cost;
        spec=p_specs;
        Owner_ID=own_id;
    }

    function insertRFID(string memory rfid,string memory prod_id) public
    {
        RFID=rfid;
    }

    //Creating Defence Supply chain participants
    function createParticipant(string memory name ,string memory pass,address u_add, string memory cin ,string memory utype) public returns (uint){
        uint user_id = _u_id++; 
        participants[user_id]._userName = name ;
        participants[user_id]._passWord = pass;
        participants[user_id]._cin = cin;
        participants[user_id]._address = u_add;
        participants[user_id]._userType = utype;
        participants[user_id].rating=5;
        if(keccak256(bytes(cin))==keccak256("AB123") ||
        keccak256(bytes(cin)) ==keccak256("DM787") ||
        keccak256(bytes(cin)) ==keccak256("CN574") ||
        keccak256(bytes(cin)) ==keccak256("ZT411") ||
        keccak256(bytes(cin)) ==keccak256("TD841"))
        {
            if(keccak256(bytes(utype))==keccak256("Main Manufacturer"))
            {
                participants[user_id].rating=5;
            }
            if(keccak256(bytes(utype))==keccak256("Manufacturer"))
            {
                participants[user_id].rating=4;
            }
            if(keccak256(bytes(utype))==keccak256("Startup"))
            {
                participants[user_id].rating=3;
            }
            return user_id;
        }

        else{
            revert('Not Allowed');
        }
    }
    
    //Updating  of Subparts, Spareparts of the main weapon
    function newSub_Product(uint comp_id, string memory name ,uint p_cost ,string memory p_specs ,string memory p_review) public returns (uint) {
            uint product_id = _p_id++;
            products[product_id]._product_name = name;
            products[product_id]._comp_id = comp_id;
            products[product_id]._product_cost = p_cost;
            products[product_id]._product_specs =p_specs;
            products[product_id]._product_review =p_review;
            //products[product_id]._product_owner = participants[own_id]._address;
            products[product_id]._manufacture_date = now;
            return product_id;
    }

    function ownerSub(uint _p_id) public view returns (string memory) {
        return participants[products[_p_id]._comp_id]._userName;
    }

    function claimOwner(string memory O_ID,string memory comp_name) public returns (string memory){
        if(keccak256(bytes(O_ID)) == keccak256(bytes(Owner_ID))){
            Owner = comp_name;
        return Owner;
        }
    }

    function getParticipant(uint p_id) public returns (string memory ,address,string memory ) {
        return (participants[p_id]._userName,participants[p_id]._address,participants[p_id]._userType);
    }
    
    function getProduct_details(uint prod_id) public returns (string memory ,uint,string memory ,string memory,address,uint){
        return (products[prod_id]._product_name,products[prod_id]._product_cost,products[prod_id]._product_specs,products[prod_id]._product_review,products[prod_id]._product_owner,products[prod_id]._manufacture_date);
    }

    
    function transferOwnership_product(uint user1_id ,uint user2_id, uint prod_id) public returns(uint) {

        participant memory p1 = participants[user1_id]; //Buyer
        participant memory p2 = participants[user2_id]; //Seller


        products[prod_id].buy[transfercount]=user1_id;
        products[prod_id].sell[transfercount]=user2_id;

        transfercount=transfercount+1;


        prevtrack=user1_id; 

                return transfercount;
    }


    function displaychain() public view returns(string memory)  // Displays the entire supply chain
    {
        string memory ret="";
        string memory buyer="";
        string memory seller="";
        
        
        for(uint i=0;i<transfercount;i++)
        {

            /*buyer = participants[products.buy[i]]._userName;
            seller = participants[products.sell[i]]._userName;*/
            ret = string(abi.encodePacked(ret,"\n",transfercount," : ",seller," -> ",buyer,"\n"));
        }
        return ret;
    }

    function track() public view returns (uint, string memory)
    { 
        return (prevtrack, participants[prevtrack]._userName);
    }


    function uint2str(uint256 _i) internal pure returns (string memory str)
    {
        if (_i == 0)
        {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0)
        {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0)
        {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }

    function userLogin(string memory user, string memory password) public returns (uint)
    {
        if(keccak256(bytes(user))==keccak256("Military")){
            if(keccak256(bytes(password))==keccak256("Military")){
                access=1;
            }
        }

        if(keccak256(bytes(user))==keccak256("Judiciary")){
            if(keccak256(bytes(password))==keccak256("Judiciary")){
                access=1;
            }
        }
        
    }

    function derating(uint comp_id, uint newrate) public returns (uint)
    {
        if(access==1 || access==2)
        {
            participants[comp_id].rating=newrate;
        }

        else
        {
            revert('Unauthorized Access');
        }
    }

    
    }
        