#!/bin/bash

# Copyright (C) 2023 Raoul Scarazzini <rasca@mmul.it>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

usage() {
    echo "$0 --project <kpa project> --kpa-yml <kpa yaml> --verbose"
    echo ""
    echo " -p|--project: The name of the <kpa project> stored under the projects folder"
    echo "               that contains the common/settings.yml general file."
    echo ""
    echo " -y|--yml:     The name of the KPA yaml document to be processed."
    echo ""
    echo " -v|--verbose: Display Ansible playbook output."
}

while [ "x$1" != "x" ]; do
    case "$1" in
        --verbose|-v)
            ANSIBLE_VERBOSE='-v'
            ;;

        --project|-p)
            KPA_PROJECT=$2
            shift
            # Check settings file
            if [ ! -f "projects/${KPA_PROJECT}/common/settings.yml" ]
             then
               echo "A setting.yml file must exists under projects/${KPA_PROJECT}/common/!"
               echo ""
               usage
               exit 1
            fi
            ;;

        --yml|-y)
            KPA_YML=$2
            shift
            # Check kpa yaml
            if [ ! -f "projects/${KPA_PROJECT}/${KPA_YML}" ]
             then
               echo "Unable to get projects/${KPA_PROJECT}/${KPA_YML} file!"
               echo ""
               usage
               exit 1
            fi
            ;;
        --help|-h|-?)
            usage
            exit
            ;;

        --) shift
            break
            ;;

        -*) echo "ERROR: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;

        *)  break
            ;;
    esac

    shift
done

if [ "x${KPA_PROJECT}" == "x" ]
 then
  echo "Error: you need to declare the KPA project name with the -p|--project option!"
  echo ""
  usage
  exit 1
fi

if [ "x${KPA_YML}" == "x" ]
 then
  echo "Error: you need to declare the KPA document yaml file with the -y|--yml option!"
  echo ""
  usage
  exit 1
fi

echo -n "Rendering ${KPA_PROJECT} KPA project for ${KPA_YML} file -> "

# Launch ansible playbook
export ANSIBLE_INVENTORY_UNPARSED_WARNING=False
export ANSIBLE_LOCALHOST_WARNING=False

ANSIBLE_COMMAND="ansible-playbook ${ANSIBLE_VERBOSE}
  -e @projects/${KPA_PROJECT}/common/settings.yml
  -e @projects/${KPA_PROJECT}/${KPA_YML}
  playbooks/kpa_generator.yml"

[ "x${ANSIBLE_VERBOSE}" == "x" ] && ${ANSIBLE_COMMAND} &> /dev/null || ${ANSIBLE_COMMAND}

if [ $? -ne 0 ]
 then
  echo "Errors!"
  exit 1
 else
  echo "Completed."
fi
