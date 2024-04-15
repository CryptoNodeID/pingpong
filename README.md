### Prerequisite :
#### Ensure 'git' already installed
    apt-get update -y && apt-get install git -y
### Steps
#### Clone this repository :
    git clone https://github.com/CryptoNodeID/pingpong.git
#### run setup command : 
    cd pingpong && chmod ug+x *.sh && ./setup.sh
#### follow the instruction and then run below command to start the node :
    ./start_pingpong.sh && ./check_log.sh
### Available helper tools :
    ./start_pingpong.sh
    ./stop_pingpong.sh
    ./check_log.sh