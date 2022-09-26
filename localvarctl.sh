#!/bin/bash

set -e

verb=$1

echo "$0: launched with:"
echo -e "\tuser:\t$USER"
echo -e "\thome:\t$HOME"
echo -e "\tverb:\t$verb"

function ensure_local_stu_var() {
	if [ ! -d /var/stu ]; then
		echo -e "$0: error: Directory /var/stu must already have been created by root. Please report this to your system's adminstrator." >&2
		return 1
	fi
	mkdir -pv /var/stu/$USER/
	chmod -v go-rwx /var/stu/$USER/
	echo " --> done: ensure_local_stu_var"
}

function ensure_moz_symlink() {
	if [ ! -h ~/.mozilla ]; then
		echo "$0: ~/.mozilla is a directory where it should be a symbolic link, moving..."
		if [ -d ~/.mozilla ]; then
			mv -v ~/.mozilla /var/stu/$USER/.mozilla
		else
		    mkdir -p /var/stu/$USER/.mozilla
		fi
		ln -sf /var/stu/$USER/.mozilla ~/.mozilla
	fi

	echo " --> done: ensure_moz_symlink"
}

function ensure_local_cache() {
	if [ ! -h ~/.cache ]; then
		echo "$0: ~/.cache is a directory where it should be a symbolic link, moving..."
		if [ -d ~/.cache ]; then
			rm -frv /tmp/$USER
			mv -v ~/.cache /tmp/$USER
		fi
		ln -sf /tmp/$USER ~/.cache
	fi
	if [ ! -d /tmp/$USER ]; then
	    mkdir -p /tmp/$USER
	fi

	echo " --> done: ensure_local_cache"
}

function dir_is_not_empty() {
	if [ $(ls -A "$1" | wc -l) -ne 0 ]; then
		return 0
	else
		return 1
	fi

}

function restore() {
	if [ -f ~/.local/stu/state.tar.gz ]; then
		echo " --> stu state found in home directory, attempting to extract..."
		rm -frv /var/stu/$USER-old
		mv -fv /var/stu/$USER /var/stu/$USER-old
		ensure_local_stu_var
		cd /var/stu/$USER
		N_EXTRACTED=$(tar xzvf ~/.local/stu/state.tar.gz | wc -l) || (echo -e "$0: error:\tFailed state extraction. Your local state is not up to date." >&2 && false)
		echo " --> extracted $N_EXTRACTED file·s!"
		cd -
	else
		echo -e "$0: warning: There is no state to restore. I am not doing anything." >&2
	fi
	echo " --> done: restore"
}

function save() {
	if dir_is_not_empty /var/stu/$USER; then
		cd /var/stu/$USER
		N_ARCHIVED=$(tar cvzf ~/.local/stu/state.new.tar.gz . | wc -l) || (echo -e "$0: error: Failed to archive current state. You may still be able to use your old state." >&2 && false)
		cd -
		echo " --> saved $N_ARCHIVED file·s!"
		if [ -f ~/.local/stu/state.tar.gz ]; then
			mv -v ~/.local/stu/state.tar.gz ~/.local/stu/state.old.tar.gz
		fi
		mv -v ~/.local/stu/state.new.tar.gz ~/.local/stu/state.tar.gz
	fi
	echo " --> done: save"
}

ensure_local_stu_var
ensure_moz_symlink
ensure_local_cache
mkdir -pv ~/.local/stu/

if [ "$verb" = "restore" ]; then
	restore
elif [ "$verb" = "save" ]; then
	save
fi
