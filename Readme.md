# An UptimeRobot plugin for BitBar

<a href="https://getbitbar.com" target="_blank" rel="noopener noreferrer">BitBar</a> is a handy tool for MacOS status bar, whose functionality is based on plugins.

This repo has the source code for a plugin that integrates <a href="https://uptimerobot.com" target="_blank" rel="noopener noreferrer">UptimeRobot</a> into BitBar.

![Plugin screenshot](https://raw.githubusercontent.com/sergeypedan/bitbar-uptime-robot-dashboard/master/BitBar%20UptimeRobot%20plugin%20screenshot.png)

## Install

This assumes you have BitBar already installed.

### Manually

1. Add a monitor to UptimeRobot.
1. Get a *read-only* API key from UptimeRobot (from the <a href="https://uptimerobot.com/dashboard.php#mySettings" target="_blank">Settings page</a>.)
1. Put your API key into a file `bitbar.conf` in `~/.config/` directory. You can do it from Terminal as follows:

	```sh
	echo 'UPTIME_ROBOT_API_KEY = "12345-asdf-7890"' > ~/.config/bitbar.conf
	```

1. Save the plugin <a href="https://raw.githubusercontent.com/sergeypedan/bitbar-uptime-robot-dashboard/master/uptime_robot.rb" target="_blank">source code</a> as a text file `uptime_robot.rb` (any file name will work).
1. Put it into BitBar plugin folder (you can find its location from BitBar menu).
1. Assign file permissions for that file:

	```sh
	cd <plugin directory>
	chmod +x "uptime_robot.rb"
	```

1. Refresh BitBar from menu — the new plugin should be up and running

### From BitBar site

Not submitted yet
