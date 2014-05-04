#!/bin/bash

# Ignore CR's in scripts
#	and ignore DOS style paths
set -o igncr || exit 1
export CYGWIN="${CYGWIN} nodosfilewarning"

# Dependencies check
if [[ `which node 2>/dev/null | wc -l` -eq 0 ]]; then
	echo -e "\x1b[31;1mNODE.JS NOT FOUND. CANNOT CONTINUE.\x1b[0m"
	exit 1
fi

if [[ `which npm 2>/dev/null | wc -l` -eq 0 ]]; then
	echo -e "\x1b[31;1mNPM NOT FOUND. CANNOT CONTINUE.\x1b[0m"
	exit 1
fi

if [[ `which python | wc -l` -eq 0 ]]; then
	echo -e "\x1b[31;1mPYTHON NOT FOUND. CANNOT CONTINUE.\x1b[0m"
	exit 1
fi

if [[ `python --version 2>&1` != "Python 2.7"* ]]; then
	echo -e "\x1b[31;1mPYTHON 2.7.x NOT FOUND. CANNOT CONTINUE.\x1b[0m"
	exit 1
fi

if [[ `which clang | wc -l` -eq 0 ]]; then
	echo -e "\x1b[31;1mCLANG NOT FOUND. CANNOT CONTINUE.\x1b[0m"
	exit 1
fi

if [[ `which grunt 2>/dev/null | wc -l` -eq 0 ]]; then
	npm install -g grunt-cli || exit 1
fi

if [[ `which bower 2>/dev/null | wc -l` -eq 0 ]]; then
	npm install -g bower || exit 1
fi

# ACE
cd ./ace
npm install || exit 1
node ./Makefile.dryice.js || exit 1
cd ..

# Buzz
cd ./buzz
npm install || exit 1
grunt || exit 1
cd ..

# ez_setup
cd ./ez_setup
export PYTHONPATH=`cygpath -w $(pwd)`
cd ..

# GitPython
cd ./GitPython
python ./setup.py install || exit 1
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
cat skulpt.py | sed -e "s/\#jsengine/jsengine/" | sed -e "s/rhino/node/g" | python - dist -v || exit 1
cd ..

# PHP.js
cd ./phpjs
npm install || exit 1
grunt --force || exit 1
cd ..

# Emscripten
cd ./emscripten
npm install || exit 1
emmake
export PATH=$PATH:`pwd`
cd ..

# asm.js
cd ./asmjs
npm install || exit 1
cd ..

# Log
echo -e "\n\n\x1B[32;1mCOMPLETED SUCCESSFULLY.\x1B[0m"