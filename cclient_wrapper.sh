#!/usr/bin/env bash

# Copyright (c) 2022 Dieter Peeters
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

CONFIG_FILE=~/.catoconfig
CCLIENT=cclient.sh
CSTATUS=status.sh
PASS_FILE=cato_password.cfg
COOKIE_FILE=cookie.bin
BG_CONNECTION_WAIT=3

usage() {
	echo "usage: $0 [logout|login|start|start-bg|restart|restart-bg|stop|status|connected|help]"
}

usage_config() {
	echo "To configure, create a file $1 with permissions 600, having contents:"
	echo "catodir=[install directory of Cato VPN client]"
	echo "account=[your Cato account]"
	echo "user=[your Cato username]"
	echo "#pass=[your Cato password] # optional and less safe. Only used for 'login' command. In all other cases, it's asked on client start when needed."
}

require_config_file() {
	if [ ! -f "$1" ]; then
		echo "Configfile $1 not found"
		echo ""
		usage_config $1
		exit 2
	fi
	if [ ! $(stat -c %a $1) = "600" ]; then
		echo "Set file permissions of $1 to 600"
		exit 3
	fi
}

require_variable() {
	if [ -z "${!1}" ]; then
		echo "No value for '$1'. Add a line in form:"
		echo "$1=[$2]'"
		exit 4
	fi
}

require_dir() {
	if [ ! -d $1 ]; then
		echo "Directory $1 does not exist"
		exit 5
	fi
}

load_config_and_set_cwd() {
	require_config_file $1
	source <(grep -E '^(catodir|account|user|pass)\s*=' $1)
	require_variable catodir "install directory of Cato VPN client"
	require_variable account "your Cato account"
	require_variable user "your Cato username"
	require_dir "$catodir"
	cd $catodir
}

require_cclient_running() {
	if [ -z $(pgrep -x $CCLIENT) ]; then
		echo "Client wrapper is not running or failed to start"
		exit 6
	fi
}

check_client_connected_and_exit() {
	require_cclient_running
	CONN_STATUS=$(./$CSTATUS | grep -E "^state" | sed -r 's/^.*=\s*(\S*)\s*/\1/')
	if [ -z "$CONN_STATUS" ]; then
		echo "Connection status could not be fetched."
		exit 7
	fi
	if [ "$CONN_STATUS" != "STATE_CONNECTED" ]; then
		echo "Client failed to connect, connection status = $CONN_STATUS"
		echo "Start/restart in the foreground to resolve manually."
		exit 8
	fi
	echo "Client is connected, connection status = $CONN_STATUS"
	exit 0
}

force_logout() {
	sudo sh -c "./$CCLIENT stop 2>&1 > /dev/null"
	sudo rm -f "./$PASS_FILE" "./$COOKIE_FILE"
}

case $1 in
	logout|login|start|start-bg|restart|restart-bg|stop|status|connected)
		# fallthrough to next case-construct for commands that need the config
		;;
	help)
		usage
		echo ""
		usage_config $CONFIG_FILE
		exit 0
		;;
	*)
		usage
		exit 1
		;;
esac

load_config_and_set_cwd $CONFIG_FILE

case $1 in
	logout)
		force_logout
		;;
	login)
		force_logout
		if [ -z "$pass" ]; then
			sudo ./$CCLIENT start --account=$account --user=$user
		else
			sudo sh -c "while [ ! -f ./$COOKIE_FILE ]; do sleep 0.1; done && ./$CCLIENT stop 2>&1 > /dev/null" & # kill the process to keep the password off the process list
			trap "excode=$?; sudo pkill -9 -P $!; echo $excode;" EXIT
			disown
			sudo ./$CCLIENT start --account=$account --user=$user --password=$pass
		fi
		;;
	start)
		sudo ./$CCLIENT start --account=$account --user=$user
		;;
	start-bg)
		sudo sh -c "./$CCLIENT start --account=$account --user=$user 2>&1 > /dev/null &"
		sleep $BG_CONNECTION_WAIT
		check_client_connected_and_exit
		;;
	restart)
		sudo ./$CCLIENT restart --account=$account --user=$user
		;;
	restart-bg)
		sudo sh -c "./$CCLIENT restart --account=$account --user=$user 2>&1 > /dev/null &"
		sleep $BG_CONNECTION_WAIT
		check_client_connected_and_exit
		;;
	stop)
		sudo ./$CCLIENT stop
		;;
	status)
		./$CSTATUS
		;;
	connected)
		check_client_connected_and_exit
		;;
esac
