# Cato VPN Client Wrappers Wrapper

Wrapper-script around the Cato VPN Client wrapper-scripts around the Cato Client binary. 😶

A quick one-off bash-script to park in my `~/bin` directory and facilitate some operations which I frequently use.  

I found the Cato VPN wrapper a bit of a hassle and found minimal documentation, so I'm sharing this.

## Disclaimer

I'm not affiliated with Cato Networks. I made this script for myself, to facilitate using the Cato VPN client wrapper.

All product names, logos, brands, trademarks and registered trademarks are property of their respective owners.
All company, product and service names used in this repository are for identification purposes only.
Use of these names, trademarks and brands does not imply endorsement.

For info about Cato Networks, see their website: https://www.catonetworks.com .

## MIT License
This code is licensed under the MIT license. You can find it in [LICENSE](./LICENSE).

## Can it be improved?
Sure, likely a lot, probably starting with removal of sudo-use, but it works. I have other priorities to focus my time on.

If you find it helpful, feel free to use or fork the code within limits of the specified [MIT license](./LICENSE).  
Do know that no support will be given in any way, shape or form, unless I feel like spending time on it.

## Compatibility
Tested on Ubuntu 20.04.4 LTS (focal).
```
$> lsb_release -a
Distributor ID:	Ubuntu
Description:	Ubuntu 20.04.4 LTS
Release:	20.04
Codename:	focal
```  
Tested with Cato VPN client for Ubuntu 18+. 
```
$> ./client --version
... --------------------------------------
... client:  2.2.0.3 - v2.2.0-0-g8665fbf - ...
... catolib: 1.4 - win_4.8-54-g0698a82 - ...
... openssl: OpenSSL 1.1.0i  14 Aug 2018, platform: linux-x86_64, ...
... --------------------------------------
... done
```

## Install
Copy the script somewhere in the PATH and make it executable. Example below uses `~/bin` as target directory.
```bash
$> cp /your/dir/cclient_wrapper.sh ~/bin/
$> chmod 700 ~/bin/cclient_wrapper.sh
```
## Config
Configuration values are put in `~/.catoconfig`. 

Configured values will the passed to the Cato client wrapper when needed.  
The script does not support passing other arguments to the Cato client wrapper.  

### Required
```bash
catodir=[install directory of Cato VPN client]
account=[your Cato account]
user=[your Cato username]
```

### Optional
```bash
pass=[your Cato password] # optional and less safe
```
For those who do not want to remember a password or store it elsewhere.  
The pass-value is only picked up by the `login` command.  
For any other commands, the password is asked on client start when needed.

### Permissions
Set `~/.catoconfig` permissions to `600`.
```bash
$> chmod 600 ~/.catoconfig
```

## Commands

### (no arguments)
Script will be minimally helpful. Can't build a healthy relationship without some arguments.
```bash
$> cclient_wrapper.sh 
```
### connected
Show client connection status.
```bash
$> cclient_wrapper.sh connected 
```
### help
Show usage and config help.
```bash
$> cclient_wrapper.sh help 
```
### login
Force logout and start the client. The client will ask for the password, unless it was specified in the config.   
When using the password from the configfile, the client will be stopped after the login-cookie is saved.  
This behaviour avoids keeping the plaintext password in the processlist (yikes).
```bash
$> cclient_wrapper.sh login 
```
### logout
Force logout, i.e. stop the client and purge login credentials stored by the client.
```bash
$> cclient_wrapper.sh logout 
```
### restart
Stop the client and start the client in the foreground.
```bash
$> cclient_wrapper.sh restart 
```
Stop the client and start the client in the background.
```bash
$> cclient_wrapper.sh restart-bg
```
### start
Start the client in the foreground. Useful for debugging and providing credentials.
```bash
$> cclient_wrapper.sh start 
```
Start the client in the background. Credentials can not be input.
```bash
$> cclient_wrapper.sh start-bg 
```
### status
Show all client status details.
```bash
$> cclient_wrapper.sh status 
```
### stop
Stop running, you vpn client, lest we unleash the kill commands from the depths of shell.
```bash
$> cclient_wrapper.sh stop 
```
## Bash completion
You can copy the completion script [cclient_wrapper_sh_completions](./cclient_wrapper_sh_completions) into directory `/etc/bash_completion.d`.
```bash
$> sudo cp cclient_wrapper_sh_completions /etc/bash_completion.d/
```
### Alias
For ease of use, you could alias the wrapper in your `~/.bash_aliases`, or `~/.bashrc`.
```bash
alias some_alias="/your/dir/cclient_wrapper.sh"
```
### Completion on the alias
_The method below works for me, YMMV._

The goal here is to register the alias to `complete` in the same way as the original wrapper script, so bash completion works for the alias.

First, check if the `cclient_wrapper.sh` is registered with `complete`.
```bash
$> complete | grep cclient_wrapper.sh
complete ...something something... cclient_wrapper.sh
```
It should output a line starting with `complete` and ending in `cclient_wrapper.sh`.  
If not, the completion script was not loaded. Fix it before doing the next step.

When the above works, register the bash completion for the alias, based on the completion of `cclient_wrapper.sh`. 
```bash
source <(complete | grep cclient_wrapper.sh | sed -e "s/cclient_wrapper\.sh\$/some_alias/")
```
You can put this line in your `~/.bash_rc`, or other startup script, so it runs automatically.

## Releases

### 20220308 v0.1.0

- added basic operations
- added bash completion
- added readme

## Roadmap

- declare feature completeness