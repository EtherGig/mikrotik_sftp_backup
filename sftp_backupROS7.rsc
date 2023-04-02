# version: 20210211
# Original Writer: TerAnYu
# Modded by: EtherGig
# For ROS v7

:log info "Starting Automatic Backup Script"
:local SFTPserverAddress "address";
:local serverport 222;
:local SFTPuser "user";
:local SFTPpass "pass";
:local dir "directory";
:local hostname [/system identity get name];
:local board [/system routerboard get model];

:local thisdate [/system clock get date]
:local thistime [/system clock get time]
:local datetimestring ([:pick $thisdate 4 6] . [:pick $thisdate 0 3] . [:pick $thisdate 7 11])
:local timetimestring ([:pick $thistime 0 2] .":" . [:pick $thistime 3 5] .":" . [:pick $thistime 6 8])
:local backupfilename ($hostname."-".$board."-".$datetimestring."_".$timetimestring)

/export terse show-sensitive file="$backupfilename"
/system backup save name="$backupfilename"

:do { [/tool fetch url="sftp://$SFTPserverAddress/$dir/$backupfilename.rsc" port=$serverport user=$SFTPuser password=$SFTPpass src-path="$backupfilename.rsc" upload=yes] 
} on-error={:log error message="SFTP upload failed: $backupfilename.rsc"}
:do { [/tool fetch url="sftp://$SFTPserverAddress/$dir/$backupfilename.backup" port=$serverport user=$SFTPuser password=$SFTPpass src-path="$backupfilename.backup" upload=yes] 
} on-error={:log error message="SFTP upload failed: $backupfilename.backup"}

/file remove "$backupfilename.rsc"

/file remove "$backupfilename.backup"

:log info "Backup Script Finished!"
