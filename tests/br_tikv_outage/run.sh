#! /bin/bash

set -eux

. run_services

. br_tikv_outage_util

load

hint_finegrained=$TEST_DIR/hint_finegrained
hint_backup_start=$TEST_DIR/hint_backup_start
hint_get_backup_client=$TEST_DIR/hint_get_backup_client

<<<<<<< HEAD

cases=${cases:-'outage outage-after-request outage-at-finegrained shutdown scale-out'}
=======
cases=${cases:-'shutdown scale-out'}
>>>>>>> 9c891884 (Optimize integration test. (#1274))

for failure in $cases; do
    rm -f "$hint_finegrained" "$hint_backup_start" "$hint_get_backup_client"
    export GO_FAILPOINTS="github.com/pingcap/br/pkg/backup/hint-backup-start=1*return(\"$hint_backup_start\");\
github.com/pingcap/br/pkg/backup/hint-fine-grained-backup=1*return(\"$hint_finegrained\");\
github.com/pingcap/br/pkg/conn/hint-get-backup-client=1*return(\"$hint_get_backup_client\")"

    backup_dir=${TEST_DIR:?}/"backup{test:${TEST_NAME}|with:${failure}}"
    rm -rf "${backup_dir:?}"
    run_br backup full -s local://"$backup_dir" &
    backup_pid=$!
    single_point_fault $failure
    wait $backup_pid

    # both case 'shutdown' and case 'scale-out' need to restart services
    stop_services
    start_services


    check
done
