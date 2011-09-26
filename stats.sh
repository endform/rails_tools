# request log stats for a given range.
# the request log analyzer uses DateTime.parse on the options
request-log-analyzer --after "2011-09-22 18:00:00 +0000" --before "2011-09-23 03:00:00 +0000" pm_prod.log