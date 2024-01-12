#!/bin/sh

export salt_length=${OPENSSL_SALT_LEN:-16}
export digest=${OPENSSL_DIGEST:-"sha256"}

function error(){
    echo -e "\033[31m$1\033[0m"
    exit 1
}

function info(){
    echo -e "\033[34m$1\033[0m"
}

function ok(){
    echo -e "\033[32m$1\033[0m"
}

function warn(){
    echo -e "\033[33m$1\033[0m"
}


function br_encrypt(){
  openssl enc -e -pbkdf2  -saltlen $salt_length  -pass env:Password -aes-256-cbc -md $digest
}
function br_decrypt(){
  openssl enc -d -pbkdf2  -saltlen $salt_length -pass env:Password -aes-256-cbc -md $digest
}

function backup_dir_to_rclone_remote () {
  [[ -d $1 ]] || error "$1 not exists or not a directory"
  info "Backup $1 to $2"
  tar -cpf - -C $1 . | pbzip2 | br_encrypt | rclone rcat $2
}

function restore_dir_from_rclone_remote () {
  [[ -d $1 ]] || mkdir -p $1
  [[ -d $1 ]] || error "$1 not exists or not a directory"
    info "Restore $1 from $2"
  rclone cat $2 | br_decrypt | pbzip2 -d | tar -xf - -C $1
}