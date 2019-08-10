# An UptimeRobot plugin for BitBar

<a href="https://getbitbar.com" target="_blank" rel="noopener noreferrer">BitBar</a> is a handy tool for MacOS status bar, whose functionality is based on plugins.

This repo has the source code for a plugin that integrates <a href="https://uptimerobot.com" target="_blank" rel="noopener noreferrer">UptimeRobot</a> into BitBar.

![Plugin screenshot](https://raw.githubusercontent.com/sergeypedan/bitbar-uptime-robot-dashboard/master/screenshot.png)


## Install

This assumes you have BitBar already installed. Otherwise you can install it from the <a href="https://getbitbar.com" target="_blank" rel="noopener noreferrer">website</a> or as Brew cask (better):

```sh
brew cask install bitbar
```

### Manually

1. Add a monitor to UptimeRobot.
1. Get a *read-only* API key from your UptimeRobot <a href="https://uptimerobot.com/dashboard.php#mySettings" target="_blank" rel="noopener noreferrer">Settings page</a>.
1. Put that API key into file `~/.config/bitbar.conf`. You can do it from Terminal as follows:

	```sh
	echo 'UPTIME_ROBOT_API_KEY = "12345-asdf-7890"' > ~/.config/bitbar.conf
	```

1. Find your BitBar plugin folder location from BitBar menu.
1. Save the plugin <a href="https://raw.githubusercontent.com/sergeypedan/bitbar-uptime-robot-dashboard/master/uptime_robot.rb" target="_blank" rel="noopener noreferrer">source code</a> as a text file in your BitBar plugin folder. Any file name will work, but better name it `uptime_robot.rb` for clarity.
1. Assign file permissions for that file:

	```sh
	cd <plugin directory>
	chmod +x "uptime_robot.rb"
	```

1. Refresh BitBar from menu — the new plugin should be up and running

### From BitBar site

Not submitted yet


## Requirements

1. Ruby 2.0+ must be installed. Usually MacOS comes with Ruby 2.3 pre-installed. Otherwise you can install it with <a href="https://github.com/postmodern/ruby-install" target="_blank" rel="noopener noreferrer">ruby-install</a>.
1. Ruby must be available to `/usr/bin/env`. Usually it is.
