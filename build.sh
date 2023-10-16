#!/bin/bash

# Args management
help()
{
    echo "Usage: build [ -p | --pip-req ]
               [ -a | --apt-req ]
               [ -h | --help  ]
	       -- <docker build args>
	  Options:
    	     -h \t\t\tshow this help text
    	     -p | --pip-req\t specify the path of the pip requirements.txt file
	     -a | --apt-req\t specify the path of the apt requirements file"
    exit 2
}

SHORT=p:,a:,h
LONG=pip-req:,apt-req:,help
OPTS=$(getopt -a -n $0 --options $SHORT --longoptions $LONG -- "$@")

VALID_ARGUMENTS=$# # Returns the count of arguments that are in short or long options

if [ "$VALID_ARGUMENTS" -eq 0 ]; then
  help
fi

pip_req_file=requirements.txt
apt_req_file=apt_requirements.txt
eval set -- "$OPTS"
while :
do
  case "$1" in
    -p | --pip-req )
      pip_req_file="$2"
      shift 2
      ;;
    -a | --apt-req )
      apt_req_file="$2"
      shift 2
      ;;
    -h | --help)
      help
      ;;
    --)
      shift;
      break
      ;;
    *)
      echo "Unexpected option: $1"
      help
      ;;
  esac
done

# Main

USERNAME=`whoami`
USER_UID=`id -u $USERNAME`
USER_GIDS=`id -G`
USER_GNAMES=`groups`

IFS=" " read -ra group_ids <<< "$USER_GIDS"
IFS=" " read -ra group_names <<< "$USER_GNAMES"

USER_GADD_ARGS=
for i in ${!group_ids[@]}; do
   USER_GADD_ARGS="${group_ids[$i]} ${group_names[$i]}; $USER_GADD_ARGS";
done

docker build \
	--build-arg USERNAME=$USERNAME \
	--build-arg USER_UID=$USER_UID \
	--build-arg USER_GADD_ARGS="$USER_GADD_ARGS" \
	--build-arg USER_GNAMES="$USER_GNAMES" \
	--build-arg PIP_REQ_FILE="$pip_req_file" \
	--build-arg APT_REQ_FILE="$apt_req_file" \
	"$@"
