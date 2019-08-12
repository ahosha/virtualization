#!/bin/bash

# NOTE - this script expects to be run from the project root directory
CWD=$(pwd)
#RESOURCE_DIR=${CWD}/fvt/src/test/resources/
PROVISIONING_DIR=${CWD}/provisioning/
IP_FILE=${PROVISIONING_DIR}/vsphere_ip_box1.env
#IP_FILE2=${PROVISIONING_DIR}/vsphere_ip_box2.env
TERRAFORM_DIR=${TERRAFORM_DIR:-${PROVISIONING_DIR}}
SSH_KEY=${PROVISIONING_DIR}.keys/id_rsa
SSH_OPTS="-i ${SSH_KEY} -o StrictHostKeyChecking=no"

## A random identifier to distinguish VM instance names
DEFAULT_HOST_ID=$(LC_CTYPE=C < /dev/urandom tr -dc A-Za-z0-9 | head -c 8)
ANCHOR_HOST_ID="virtualization"
HOST_ID=${HOST_ID:-${DEFAULT_HOST_ID}}

fatal()
{
    echo "FATAL: $1"
    exit ${2:-1}
}

#clean_toml(){
#
#echo "Cleaning anchor.toml file for old IP's"
#
#sed -i -e  "s/ip =.*/ip = /" ${CWD}/conf/anchor.toml
#
#}
run()
{
    echo "RUNNING [$(pwd)]: $@"
    "$@"
}

validate()
{
    [[ -n ${TF_VAR_vsphere_user} ]] || fatal "vSphere user must be in environment as TF_VAR_vsphere_user"
    [[ -n ${TF_VAR_vsphere_password} ]] || fatal "vSphere password must be in environment as TF_VAR_vsphere_password"
}

terraform_init()
{
    [[ -d ${TERRAFORM_DIR}/.terraform ]] \
        || ( echo "Initiaizing terraform in ${TERRAFORM_DIR}" ; run terraform init )
}

create_test_host()
{
    # Create the host
    ( cd ${TERRAFORM_DIR} ; echo yes | run terraform apply -var "host_id=${HOST_ID}" ${PROVISIONING_DIR} ) \
        || fatal "failed to create test VM"

    # Record IP of new host
    ( cd ${TERRAFORM_DIR} ; terraform output ip | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" > ${IP_FILE} ) || fatal "failed to determine test host IP"
#    ( cd ${TERRAFORM_DIR} ; terraform output ip2 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"> ${IP_FILE2} ) || fatal "failed to determine test host IP2"
    TEST_HOST_IP=$(cat ${IP_FILE})
    [[ -n ${TEST_HOST_IP} ]] || fatal "No IP found in ${IP_FILE}"
#       TEST_HOST_IP2=$(cat ${IP_FILE2})
#    [[ -n ${TEST_HOST_IP2} ]] || fatal "No IP found in ${IP_FILE}"


}

copy_files()
{
    chmod 600 ${SSH_KEY}

#    clean_toml

#    sed -i -e  '/ip =/s/$/ '\"${TEST_HOST_IP2}\"'/' ${CWD}/conf/anchor.toml

#    run scp ${SSH_OPTS} ${CWD}/conf/anchor.toml root@${TEST_HOST_IP}:/etc/ha/anchor \
#        || fatal "Failed to copy anchor.toml to target host ${TEST_HOST_IP}"
#
#    clean_toml
#
#    sed -i -e  '/ip =/s/$/ '\"${TEST_HOST_IP}\"'/' ${CWD}/conf/anchor.toml
#
#   run scp ${SSH_OPTS} ${CWD}/conf/anchor.toml root@${TEST_HOST_IP2}:/etc/ha/anchor \
#        || fatal "Failed to copy anchor.toml to target host ${TEST_HOST_IP2}"
#
#     clean_toml

        run scp ${SSH_OPTS} ${PROVISIONING_DIR}.keys/id_rsa root@${TEST_HOST_IP}:/root/.ssh/id_rsa \
        || fatal "1 Failed to copy keys to target host ${TEST_HOST_IP}"

        run scp ${SSH_OPTS} ${PROVISIONING_DIR}.keys/id_rsa.pub root@${TEST_HOST_IP}:/root/.ssh/id_rsa.pub \
        || fatal "2 Failed to copy keys to target host ${TEST_HOST_IP}"

#        run scp ${SSH_OPTS} ${PROVISIONING_DIR}.keys/id_rsa root@${TEST_HOST_IP2}:/root/.ssh/id_rsa \
#        || fatal "Failed to copy keys to target host ${TEST_HOST_IP2}"
#
#        run scp ${SSH_OPTS} ${PROVISIONING_DIR}.keys/id_rsa.pub root@${TEST_HOST_IP2}:/root/.ssh/id_rsa.pub \
#        || fatal "Failed to copy keys to target host ${TEST_HOST_IP2}"

#        run scp ${SSH_OPTS} -r ${RESOURCE_DIR} root@${TEST_HOST_IP}:/ \
#        || fatal "3 Failed to copy keys to target host ${TEST_HOST_IP}"

#        run scp ${SSH_OPTS} -r ${RESOURCE_DIR} root@${TEST_HOST_IP2}:/ \
#        || fatal "Failed to copy keys to target host ${TEST_HOST_IP2}"



        run ssh ${SSH_OPTS} root@${TEST_HOST_IP} 'sudo chmod 600 /root/.ssh/id_rsa' || fatal "4 Failed to execute command on the target host ${TEST_HOST_IP}"
#        run ssh ${SSH_OPTS} root@${TEST_HOST_IP2} 'sudo chmod 600 /root/.ssh/id_rsa' || fatal "Failed to execute command on the target host ${TEST_HOST_IP2}"
        #Only to be used if the rsyncservice is running alone without Qradar to establish connection between two servers.
#        run ssh ${SSH_OPTS} root@${TEST_HOST_IP} "ssh-keyscan ${TEST_HOST_IP2} >> /root/.ssh/known_hosts" || fatal "Failed to establish connection with ${TEST_HOST_IP2}"



}





#------------#
#--  MAIN  --#
#------------#

validate
terraform_init
create_test_host
copy_files

