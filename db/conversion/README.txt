If you want to test the 4d connections, your will need to do several things.

The contains some libraries and files and folders.

replace /weba4d/public/ws folder with the ws folder. It is not used on the current system.

put the a4l libraries in weblib

put the rest.models.json file somewhere in the web root and change the init path in rest.a4l

make sure this code is in active4d.a4l on request

if($inurl = "/ws.@")
	$cnt := split string($inURL;".";$parts)
	if ($cnt = 3)
		_request{"_params"} := $parts{3}
		_request{"_service"} := $parts{2}
	else
		_request{"_service"} := $parts{2}
	end if		
	$url := "/public/ws/ws.a4d"
	return($url)

I am pretty sure it is, don't think I changed it - it was an experiment that never got implemented.

I have my 4d running on port 8080, yours maybe running on 8010. Do a global search for 8080 and change to your port. Will sync later.

Add the a4dx_launch_curl method that was in the email the other day:

` a4dx_launch_curl
C_TEXT($1;$curl;$2;$params;$0;output)
$curl:=$1
$params:=$2

add an active cron task with parameters. I have it running on my machine, but not sure how If I put my machine name in or init did.

a4dx_launch_curl("curl http://localhost:8080/ws.getwork";"")

That should be about it, except active4d should be running on that machine.

It should run using stage RYLA.