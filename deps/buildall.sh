#!/bin/bash

# Force?
[[ "$1" == "--force" ]] || echo "Will fail on error..."
function checkExit() {
	if [[ "$1" == "--force" ]]; then
		echo -e "\x1B[31;1mERROR; --force specified: continuing...\x1B[0m"
	else
		exit 1
	fi
}

# Ignore CR's in scripts
#	and ignore DOS style paths
set -o igncr || checkExit
export CYGWIN="${CYGWIN} nodosfilewarning"

# Dependencies check
if [[ `which node 2>/dev/null | wc -l` -eq 0 ]]; then
	echo -e "\x1b[31;1mNODE.JS NOT FOUND. CANNOT CONTINUE.\x1b[0m"
	checkExit
fi

if [[ `which npm 2>/dev/null | wc -l` -eq 0 ]]; then
	echo -e "\x1b[31;1mNPM NOT FOUND. CANNOT CONTINUE.\x1b[0m"
	checkExit
fi

if [[ `which python | wc -l` -eq 0 ]]; then
	echo -e "\x1b[31;1mPYTHON NOT FOUND. CANNOT CONTINUE.\x1b[0m"
	checkExit
fi

if [[ `python --version 2>&1` != "Python 2.7"* ]]; then
	echo -e "\x1b[31;1mPYTHON 2.7.x NOT FOUND. CANNOT CONTINUE.\x1b[0m"
	checkExit
fi

if [[ `which clang | wc -l` -eq 0 ]]; then
	echo -e "\x1b[31;1mCLANG NOT FOUND. CANNOT CONTINUE.\x1b[0m"
	checkExit
fi

if [[ `which coffee 2>/dev/null | wc -l` -eq 0 ]]; then
	npm install -g coffee-script || checkExit
fi

if [[ `which grunt 2>/dev/null | wc -l` -eq 0 ]]; then
	npm install -g grunt-cli || checkExit
fi

if [[ `which bower 2>/dev/null | wc -l` -eq 0 ]]; then
	npm install -g bower || checkExit
fi

# ACE
cd ./ace
npm install || checkExit
node ./Makefile.dryice.js || checkExit
cd ..

# Buzz
cd ./buzz
npm install || checkExit
grunt || checkExit
cd ..

# ez_setup
cd ./ez_setup
export PYTHONPATH=`cygpath -w $(pwd)`
cd ..

# GitPython
cd ./GitPython
python ./setup.py install || checkExit
cd ..

# Skulpt
#	Whatever D8 is doesn't run on windows.
#	I just force the system to use node as the
#	Javascript engine instead, taking advantage
#	of a commented out line that forces
#	the script to use rhino. I'm assuming they
#	used it for development, and if/when it's taken
#	out I'll probably have to come up with something
#	else.
#
#	I'm doing this in here because forking the repo
#	for something small like this isn't worth it.
cd ./skulpt
cat skulpt.py | sed -e "s/\#jsengine/jsengine/" | sed -e "s/rhino/node/g" | python - dist -v || checkExit
cd ..

# PHP.js
cd ./phpjs
npm install || checkExit
grunt --force || checkExit
cd ..

# Emscripten
cd ./emscripten
npm install || checkExit
emmake
export PATH=$PATH:`pwd`
cd ..

# asm.js
cd ./asmjs
npm install || checkExit
cd ..

# Doppio
cd ./doppio
npm install || checkExit
bower install || checkExit
grunt release || checkExit
cd ../

# BashJS
cd ./bashjs
coffee -o lib/ -c src/Bash-Ansi.coffee || checkExit
cd ../

# Log
echo -e "\n\n\x1B[32;1mCOMPLETED SUCCESSFULLY.\x1B[0m"
