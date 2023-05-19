# Using KPA in CI

KPA can be used in a CI context to automate the production of slide sets after each push to your repository.

While producing new *Knowleldge Pods* or modifying existing ones you will have an automated way to get your trainings or presentations ready and versioned each time you modify something.

## How to make it work

To implement CI in KPA a container named [kpa is available at quay.io](https://quay.io/repository/mmul/), complete of this repository, the `kpa_generator` Ansible role, and the Marp and Pandoc tools. It is everything you need to automate the generation.

Your KPA project will live in a repository and should have the structure described in the [Create a KPA project](https://github.com/mmul-it/kpa/#create-a-kpa-project) chapter inside the main documentation file of this repository.

## Implement CI with GitHub Actions

Once you're done creating the structure, if you want to [automate your workflow with GitHub Actions](https://github.com/features/actions), you will need to create a file under the `.github/workflows` path, named for example `main.yml`, with these contents:

```yaml
name: Automate PDF file creation

env:
  KPA_PROJECT: myproject

on: [push]

defaults:
  run:
    working-directory: /kpa

jobs:
  lint:
    runs-on: ubuntu-latest
    container:
      image: quay.io/mmul/kpa
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Link project dir in KPA projects folder
        run: ln -vs ${GITHUB_WORKSPACE} /kpa/projects/${KPA_PROJECT}
      - name: Check project yamls
        run: yamllint -s projects/${KPA_PROJECT}/*.yml
      - name: Check markdown files for example project                          
        run: mdl projects/${KPA_PROJECT}/contents/*.md

  markdown:
    runs-on: ubuntu-latest
    needs: lint
    container:
      image: quay.io/mmul/kpa
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Link project dir in KPA projects folder
        run: ln -vs ${GITHUB_WORKSPACE} /kpa/projects/${KPA_PROJECT}
      - name: Generate markdown files
        run: for TRAINING in $(ls projects/${KPA_PROJECT}/*.yml); do
               echo "Processing ${TRAINING}";
               ansible-playbook
                 -e @${TRAINING}
                 playbooks/kpa_generator.yml;
             done
      - run: ls output
      - name: Upload markdown files
        uses: actions/upload-artifact@v3
        with:
          name: markdowns
          path: /kpa/output/**.md

  marp-pdf:
    runs-on: ubuntu-latest
    needs: markdown
    container:
      image: quay.io/mmul/kpa
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Link project dir in KPA projects folder
        run: ln -vs ${GITHUB_WORKSPACE} /kpa/projects/${KPA_PROJECT}
      - name: Download markdown files
        uses: actions/download-artifact@v3
        with:
          name: markdowns
          path: /kpa/output/
      - name: Generate Marp pdf files
        run: for TRAINING in $(ls output/*.md); do
               echo "Processing ${TRAINING}";
               marp --theme projects/${KPA_PROJECT}/common/theme.css --html --pdf --allow-local-files ${TRAINING};
             done
      - name: Upload Marp pdf files
        uses: actions/upload-artifact@v3
        with:
          name: pdfs
          path: /kpa/output/**.pdf
```

Each step is self explaining, but to give some highlights:

- There's an overall environment variable definition, `KPA_PROJECT`, that will be used in all the jobs.

- The CI will be launched for each push operation (`on: [push]`).

- The working directory of all the jobs will be `/kpa`, available in the `quay.io/mmul/kpa` container.

- There are three  jobs that will check:
  
  - The yaml linter consistency of the definition (`lint`).
  
  - The markdown files generation (`markdown`).
  
  - The pdf files generation (`marp-pdf`).
  
  Each step is dependent from the previous one and starts with `Link project dir in KPA projects folder`, a trick to put your project available in the `/kpa/projects` folder.

**Note**: that this repository itself uses GitHub actions to automatically lint the Ansible code and the yaml and then produce slides and agenda for the default `example` project, check [.github/workflows/main.yml](.github/workflows/main.yml).

## Implement CI with GitLab CI

If your repository lives inside GitLab then this is a practical example about how to use the KPA container to process a project named `myproject` using GitLab CI.

A `.gitlab-ci.yml` yaml file should contain something like this:

```yaml
image: quay.io/mmul/kpa

variables:
  KPA_PROJECT: myproject

stages:
  - lint
  - markdown
  - marp-pdf

lint:
  stage: lint
  script:
    # YAML check
    - yamllint -s *.yml
    # Markdown check
    - mdl contents/*.md

markdown:
  stage: markdown
  # Save generated markdown files
  artifacts:
    paths:
      - output/*.md
  script:
    # Create symlink in the /kpa/projects dir pointing to project dir
    - ln -vs ${CI_PROJECT_DIR} /kpa/projects/${KPA_PROJECT}
    - cd /kpa
    # Generate Marp Markdown files
    - for TRAINING in $(ls projects/${KPA_PROJECT}); do
        echo "Processing $TRAINING";
        ansible-playbook
          -e @projects/${KPA_PROJECT}/common/settings.yml
          -e @projects/${KPA_PROJECT}/$TRAINING
          playbooks/kpa_generator.yml;
      done
    # Move output folder into project dir (symlink won't work)
    - mv /kpa/output ${CI_PROJECT_DIR}/output

marp-pdf:
  stage: marp-pdf
  # Depend from output generated in the previous stage
  dependencies:
   -  markdown
  # Save generated pdf files
  artifacts:
    paths:
      - output/*.pdf
  before_script:
    # Create projects directory under output
    - mkdir output/projects
    # Create a symlink pointing to the project dir under output/projects
    - ln -vs ${CI_PROJECT_DIR} output/projects/${KPA_PROJECT}
  script:
    # Generate pdf files using marp
    - for TRAINING in $(ls output/*.md); do
        echo "Processing $TRAINING";
        marp --theme common/theme.css --html --pdf --allow-local-files $TRAINING;
      done
```

It uses the same trick of the symbolic link as the GitHub's one and it does essentially the same three main steps, or stage as GitLab calls them.

This file will be placed into your project's GitLab repository and, for every push, will look for every training or content yaml file definition and process it into a pdf file under the `output` directory, making those files available as GitLab job's artifacts.
