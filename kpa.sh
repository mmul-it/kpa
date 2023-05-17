#!/bin/bash -x

PROJECT=$1
KPA_DOC=$2

if [ ! -f "projects/${PROJECT}/kpa.config" ]
 then
  echo "No kpa-config file for project ${PROJECT}"
  exit 1
 else
  source /kpa/projects/${PROJECT}/kpa.config
fi

# Fix dependencies
ansible-galaxy install -r playbooks/roles/requirements.yml

# Generate markdown files
ansible-playbook \
  -e @${KPA_SETTINGS} \
  -e @${KPA_PROJECT_DIR}/${KPA_DOC}.yml \
  playbooks/kpa_marp_slides_generator.yml

# Marp: PDF Slides generation
marp --pdf \
     --allow-local-files \
     --html \
     --theme ${KPA_MARP_THEME} \
     ${KPA_OUTPUT_DIR}/${KPA_DOC}.md

# Pandoc: PDF agenda generation
pandoc --template=projects/example/common/example.tex \
     ${KPA_OUTPUT_DIR}/${KPA_DOC}.schedule.md \
     -o ${KPA_OUTPUT_DIR}/${KPA_DOC}.schedule.pdf
