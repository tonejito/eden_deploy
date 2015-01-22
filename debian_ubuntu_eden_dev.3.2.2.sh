#!/bin/bash
#	http://eden.sahanafoundation.org/wiki/InstallationGuidelines/Linux/Developer/Script
set -e
#
# Install a Sahana Eden Developer environment in Ubuntu/Debian
# - tested on Ubuntu 10.04 and 11.10, and Debian Wheezy
#
f_Quick() {
    MODE="quick"
}
f_Medium() {
    MODE="medium"
}
f_Full() {
    MODE="full"
}
if [[ -z "$1" ]]; then
    # Offer a menu
    echo "Welcome to the Sahana Eden Dev Installation script for Ubuntu/Debian."
    echo "This will install a working verion of Sahana Eden into /home/web2py, and chown the directory to give the specified user access."
    echo
    echo "Select the Installation Type:"
    echo
    echo "1. Medium - installs all mandatory and some common optional dependencies. It is the normal recommended option."
    echo "2. Quick - installs only mandatory dependencies. This is recommended if you are on a slow Internet connection or need to get operational quickly."
    echo "3. Full - installs all optional dependencies & the Eclipse debugger. It is only recommended if you are on a fast Internet connection & are prepared to be patient."
    echo
    # I have explicitly mentioned what the user is supposed to write,People have been trying to write things like "Full/full/Medium/medium etc" instead of 1/2/3.
    echo -n "Your choice (Enter 1/2/3 depending on your requirements) ? : "
    read choice
    case "$choice" in
      1) f_Medium ;;
      2) f_Quick ;;
      3) f_Full ;;
      *) echo "\"$choice\" is not valid" ; exit ;;
    esac
elif [[ "$1" = "quick" ]]; then
    # Set the option direct
    MODE="quick"
elif [[ "$1" = "medium" ]]; then
    # Set the option direct
    MODE="medium"
elif [[ "$1" = "full" ]]; then
    # Set the option direct
    MODE="full"
else
    echo >&2 "$1 is not a valid option!\nPlease use either 'quick', 'medium' or 'full'"
    exit 1
fi
#Update the repos
sudo apt-get update
# Install Git
sudo apt-get install git-core
# Install Python Libs
#sudo apt-get install -y python2.7 python-dateutil
sudo apt-get install -y python-lxml python-shapely python-dateutil
if [[ "$MODE" = "medium" ]]; then
    sudo apt-get -y install python-reportlab python-xlrd python-xlwt
elif [[ "$MODE" = "full" ]]; then
    sudo apt-get -y install python-reportlab python-xlrd python-xlwt
    sudo apt-get -y install python-matplotlib python-numpy
    sudo apt-get -y install eclipse-platform
fi
# Install Web2Py
cd /home
# Problem faced earlier:
#       Suppose the user enters wrong username, the script would just exit, leaving behind web2py folder in /home.
#       When the user tries to rerun the script , he would get an error message reading something like this
#      "Fatal error , web2py already exists in the path and is not an empty directory"
#       This is caused as we tried to clone the same repository, in the same previous location , where it already is present.
# Fix:
#       Just deleted web2py already present and cloned it later. This solves the issue.
#   A better solution would be to add a check if the dir exists and
#   ask the user if he wants to delete it or not
#rm -rf web2py
#if [[ "$MODE" = "full" ]]; then
# Currently need trunk
git clone git://github.com/web2py/web2py.git
#else
#    # Install the stable version
#    wget http://www.web2py.com/examples/static/web2py_src.zip
#    unzip web2py_src.zip
#fi
cat << EOF > /home/web2py/routes.py
#!/usr/bin/python
default_application = 'eden'
default_controller = 'default'
default_function = 'index'
routes_onerror = [
        ('eden/400', '!'),
        ('eden/401', '!'),
        ('eden/*', '/eden/errors/index'),
        ('*/*', '/eden/errors/index'),
    ]
EOF
# Install Eden
cd /home/web2py/applications
git clone git://github.com/flavour/eden.git
cp /home/web2py/applications/eden/modules/templates/000_config.py /home/web2py/applications/eden/models
sed -i 's|EDITING_CONFIG_FILE = False|EDITING_CONFIG_FILE = True|' /home/web2py/applications/eden/models/000_config.py
echo -n "What is your username ( Please enter your computer's username, and not your web2py username )? : "
# Maybe we should consider checking validity of username entered first , before running chown -R $username /home/web2py
read username
if id -u $username >/dev/null 2>&1; then
    chown -R $username /home/web2py
    echo "Installation is now complete - you can run Sahana either by using the Eclipse debugger or else by running:"
    echo "cd /home/web2py; python web2py.py -a eden"
    echo "Then run Sahana by pointing your web browser at http://127.0.0.1:8000"
    echo "Be patient on the 1st run as the database needs to be created"
else
    echo "username entered doesn't seem to be valid."
fi
#if ! `chown -R $username /home/web2py` ;then
#   echo "You probably entered an invalid username"
#else
#fi 2>/dev/null
