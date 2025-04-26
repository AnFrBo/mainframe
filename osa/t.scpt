tell application "QuickTime Player"
	activate
		set movieFile to ((Macintosh HD:Users:jack:Music:film:Pink:) & "02_Most Girls.m4v" as text) as alias
		open movieFile with presenting
		delay (0.25)
		present document 1
		delay (0.25)
		set looping of document 1 to true
		play document 1 with looping
end tell
