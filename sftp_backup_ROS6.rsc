:log info "Starting Automatic Backup Script"
:local SFTPserverAddress "sftp.server.address";
:local serverport 22;
:local SFTPuser "user";
:local SFTPpass "password";
:local dir "directory";
:local hostname [/system identity get name];
:local board [/system routerboard get model];

:local thisdate [/system clock get date]
:local thistime [/system clock get time]
:local datetimestring ([:pick $thisdate 7 11] ."-". [:pick $thisdate 0 3] ."-". [:pick $thisdate 4 6])
:local timetimestring ([:pick $thistime 0 2] ."-" . [:pick $thistime 3 5] ."-" . [:pick $thistime 6 8])
:local backupfilename ($hostname."-".$board."-".$datetimestring."_".$timetimestring)

#remove previous backup files
/file remove [find where name~"$hostname" type=backup]
/file remove [find where name~"$hostname" type=script]

/export terse compact file="$backupfilename"
/system backup save name="$backupfilename"

:do { [/tool fetch url="sftp://$SFTPserverAddress/$dir/$backupfilename.rsc" port=$serverport user=$SFTPuser password=$SFTPpass src-path="$backupfilename.rsc" upload=yes] 
} on-error={:log error message="SFTP upload failed: $backupfilename.rsc"}
:do { [/tool fetch url="sftp://$SFTPserverAddress/$dir/$backupfilename.backup" port=$serverport user=$SFTPuser password=$SFTPpass src-path="$backupfilename.backup" upload=yes] 
} on-error={:log error message="SFTP upload failed: $backupfilename.backup"}

:log info "Backup Script Finished!"