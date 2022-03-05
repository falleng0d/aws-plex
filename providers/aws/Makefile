# Make sure the variables are correct before using this script
SHELL:=bash
INSTANCE=

default: connect

# configure the SSH keys, generate the first migration and apply
# you should not execute this more than once after setup
init:
	./make.sh init ${INSTANCE}

connect:
	./make.sh connect ${INSTANCE}

# attaches to the instance and opens top
top:
	./make.sh top ${INSTANCE}
