pragma solidity ^0.4.17;

contract CampaignFactory {
  address[] public deployedCampaigns;

  function createCampaign(uint minimum) public {
    address newCampaign = new Campaign(minimum, msg.sender);
    deployedCampaigns.push(newCampaign);
  }

  function geDeployedCampaigns() public view returns (address[]){
    return deployedCampaigns;
  }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    modifier restricted() {
      require(msg.sender == manager);
      _;
    }

    address public manager;
    uint public approversCount;
    uint public minimumContribution;
    Request[] public requests;
    mapping(address => bool) public approvers;

    function Campaign(uint minimum, address creator) public {
        manager = creator;
        minimumContribution = minimum;
        approversCount = 0;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution); //exit unless minimum is met.

        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequests(string description, uint value, address recipient) public payable restricted {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        requests.push(newRequest);
    }

    function approveRequest(uint index) public {
        Request storage currentRequest = requests[index];

        require(approvers[msg.sender] == true);
        require(currentRequest.approvals[msg.sender] == false);

        currentRequest.approvals[msg.sender] = true;
        currentRequest.approvalCount++;
    }

    function finalizeRequest(uint index) public restricted {
        Request storage currentRequest = requests[index];

        require(currentRequest.complete == false);
        require(currentRequest.approvalCount > ( approversCount / 2));

        currentRequest.recipient.transfer(currentRequest.value);
        currentRequest.complete = true;
    }
}
