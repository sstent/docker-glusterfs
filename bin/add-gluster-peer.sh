#!/bin/bash

# Exit status = 0 means the peer was successfully joined
# Exit status = 1 means there was an error while joining the peer to the cluster

trap 'echo "Unexpected error";rm -f /tmp/adding-gluster-node; exit 1' ERR

PEER_NAME=$1
PEER_IP=$2
PEER=$PEER_IP

if [ -z "${PEER_NAME}" ]; then
   echo "=> ERROR: I was supposed to add a new gluster peer to the cluster but no peer name was specified, doing nothing ..."
   exit 1
fi

if [ -z "${PEER_IP}" ]; then
   echo "=> ERROR: I was supposed to add a new gluster peer to the cluster but no peer IP was specified, doing nothing ..."
   exit 1
fi

#Since the remote peer is not ready we need to use /etc/hosts to resolve the IP
echo "$PEER_IP $PEER_NAME">>/etc/hosts

GLUSTER_CONF_FLAG=/etc/gluster.env
SEMAPHORE_FILE=/tmp/adding-gluster-node
SEMAPHORE_TIMEOUT=120
source ${GLUSTER_CONF_FLAG}

function echo() {
   builtin echo $(basename $0): [From container ${MY_NAME}] $1
}

function detach() {
   echo "=> Some error ocurred while trying to add peer ${PEER_NAME} to the cluster - detaching it ..."
   gluster peer detach ${PEER} force
   rm -f ${SEMAPHORE_FILE}
   exit 1
}

[ "$DEBUG" == "1" ] && set -x && set +e

echo "=> Checking if I can reach gluster container ${PEER_NAME} and IP $PEER_IP ..."
if sshpass -p ${ROOT_PASSWORD} ssh ${SSH_OPTS} ${SSH_USER}@${PEER} "hostname" >/dev/null 2>&1; then
   echo "=> Gluster container ${PEER} is alive"
else
   echo "*** Could not reach gluster container ${PEER} - exiting ..."
   exit 1
fi

if gluster peer status | grep ${PEER} &>/dev/null; then
  if echo "${PEER_STATUS}" | grep "Peer in Cluster"; then
    echo "peer already added -> end"
    exit 0
  fi
fi

# Gluster does not like to add two nodes at once
for ((SEMAPHORE_RETRY=0; SEMAPHORE_RETRY<SEMAPHORE_TIMEOUT; SEMAPHORE_RETRY++)); do
   if [ ! -e ${SEMAPHORE_FILE} ]; then
      break
   fi
   echo "*** There is another container joining the cluster, waiting $((SEMAPHORE_TIMEOUT-SEMAPHORE_RETRY)) seconds ..."
   sleep 1
done

if [ -e ${SEMAPHORE_FILE} ]; then
   echo "*** Error: another container is joining the cluster"
   echo "and after waiting ${SEMAPHORE_TIMEOUT} seconds I could not join peer ${PEER_NAME}, giving it up ..."
   exit 1
fi

#Lock
echo -n ${PEER_NAME}>${SEMAPHORE_FILE}


# Check if there are rejected peers (for example due to a re-connect with a different IP)
for peerToCheck in $(gluster peer status|grep Hostname|awk '{print $2}'); do
  PEER_STATUS=`gluster peer status | grep -A2 "Hostname: ${peerToCheck}" | grep State: | awk -F: '{print $2}'`
  echo "Peer status for ${peerToCheck}: $PEER_STATUS"
  if echo "${PEER_STATUS}" | grep "Peer Rejected"; then
    for volume in $GLUSTER_VOLUMES; do
      if gluster volume info ${volume} | grep ": ${peerToCheck}:${GLUSTER_BRICK_PATH}/${volume}$" >/dev/null; then
        echo "=> Peer container ${peerToCheck} was part of volume ${volume} but must be dropped -> removing brick ..."
        NUMBER_OF_REPLICAS=`gluster volume info ${volume} | grep "Number of Bricks:" | awk '{print $6}'`
        gluster --mode=script volume remove-brick ${volume} replica $((NUMBER_OF_REPLICAS-1)) ${peerToCheck}:${GLUSTER_BRICK_PATH}/${volume} force
        #sleep 1
      fi
    done
    echo "Detaching peer before adding it again: ${peerToCheck}"
    gluster peer detach ${peerToCheck} force
    #sleep 5
  fi
done

# Probe the peer
PEER_STATUS=`gluster peer status | grep -A2 "Hostname: ${PEER}" | grep State: | awk -F: '{print $2}'`
if ! echo "${PEER_STATUS}" | grep "Peer in Cluster" >/dev/null; then
    # Peer probe
    echo "=> Probing peer ${PEER} ..."
    gluster peer probe ${PEER}
    #sleep 5
fi

for volume in $GLUSTER_VOLUMES; do

  echo "PROCESING VOLUME $volume"

	# Create the volume
	if ! gluster volume list | grep "^${volume}$" >/dev/null; then
	   echo "=> Creating GlusterFS volume ${volume}..."
	   gluster volume create ${volume} replica 2 ${MY_NAME}:${GLUSTER_BRICK_PATH}/${volume} ${PEER}:${GLUSTER_BRICK_PATH}/${volume} force || detach
     if [ -n "${GLUSTER_VOL_OPTS}" ]; then
       echo "=> Setting volume options: ${GLUSTER_VOL_OPTS}"
       gluster volume set ${volume} ${GLUSTER_VOL_OPTS}
     fi
     if [ -n "${GLUSTER_ALL_VOLS_OPTS}" ]; then
       echo "=> Setting global volume options: ${GLUSTER_ALL_VOLS_OPTS}"
       gluster volume set all ${GLUSTER_ALL_VOLS_OPTS}
     fi
     #sleep 1
	fi

	# Start the volume
	if ! gluster volume status ${volume} >/dev/null; then
	   echo "=> Starting GlusterFS volume ${volume}..."
	   gluster volume start ${volume}
	   #sleep 1
	fi

  # Check how many peers are already joined in the cluster - needed to add a replica
	NUMBER_OF_REPLICAS=`gluster volume info ${volume} | grep "Number of Bricks:" | awk '{print $6}'`
	if ! gluster volume info ${volume} | grep ": ${PEER}:${GLUSTER_BRICK_PATH}/${volume}$" >/dev/null; then
	   echo "=> Adding brick ${PEER}:${GLUSTER_BRICK_PATH}/${volume} to the cluster (replica=$((NUMBER_OF_REPLICAS+1)))..."
	   gluster volume add-brick ${volume} replica $((NUMBER_OF_REPLICAS+1)) ${PEER}:${GLUSTER_BRICK_PATH}/${volume} force || detach
	fi

done

rm -f ${SEMAPHORE_FILE}
exit 0
