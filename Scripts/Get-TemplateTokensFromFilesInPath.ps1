param([string]$Path)
gci $Path -recurse | select-string  -Pattern '\[\[(.*?)\]\]' |foreach { $_.Matches.Groups[1].Value} | sort | Select-Object -Unique