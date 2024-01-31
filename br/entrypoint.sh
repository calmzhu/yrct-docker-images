#!/bin/sh -l


function show_help(){
    cat<<EOF
Usage:
  backup        LOCAL_DIR_NAME REMOTE_RCLOEN_PATH backup local dir to rclone drive.
  restore       LOCAL_DIR_NAME REMOTE_RCLOEN_PATH restore local dir from rclone drive.
EOF
}


case $1 in
    backup)
        shift
        backup_dir_to_rclone_remote $*
        break
        ;;
    restore)
        shift
        break
        restore_dir_from_rclone_remote $*
        ;;
    "/bin/sh" | "sh")
        shift
        /bin/sh $*
        break
        ;;
    *)
        warn "unknown command"
        echo $*
        show_help
        ;;
esac
