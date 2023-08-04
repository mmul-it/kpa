# Using KPA in CI

KPA can be used in a CI context to automate the production of slide sets after
each push to your repository.

While producing new *Knowleldge Pods* or modifying existing ones you will have
an automated way to get your trainings or presentations ready and versioned each
time you modify something.

## How to make it work

To implement CI in KPA a container named **kpa** is available at [ghcr.io/mmul-it/kpa](https://ghcr.io/mmul-it/kpa),
containing the `kpa_generator` Ansible role, the Marp, and Pandoc tools.

It is everything you need to automate the generation.

Your KPA project will live in a repository and should have the structure
described in the [Create a KPA project](https://github.com/mmul-it/kpa/#create-a-kpa-project)
chapter inside the main documentation file of this repository.

## Implement CI with GitHub Actions

Once you're done creating the structure, if you want to automate your workflow
with [GitHub Actions](https://github.com/features/actions), you will need to
create a file under the `.github/workflows` path, named for example `main.yml`,
with these contents:

```yaml
name: Check and generate markdown and PDF files for mmul project

env:
  KPA_PROJECT: kpa-mmul

on: [push]

jobs:
  lint:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/mmul-it/kpa:v1.0.0
      options: --user root
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Create symlink to workspace
        run: ln -sf /__w/kpa-mmul/kpa-mmul /kpa/projects/${KPA_PROJECT}
      - name: Check project yamls
        run: yamllint -s /kpa/projects/${KPA_PROJECT}/*.yml
      - name: Check markdown files for example project
        run: mdl /kpa/projects/${KPA_PROJECT}/contents/*.md

  generate:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/mmul-it/kpa:v1.0.0
      options: --user root
    needs: lint
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Create symlink to workspace
        run: ln -sf /__w/kpa-mmul/kpa-mmul /kpa/projects/${KPA_PROJECT}
      - name: Generate files
        run: for DOC in $(ls /kpa/projects/${KPA_PROJECT}/*.yml); do
               echo "Processing $(basename ${DOC})";
               /kpa/kpa.sh -p ${KPA_PROJECT} -y $(basename ${DOC});
             done
      - name: Upload markdown files
        uses: actions/upload-artifact@v3
        with:
          name: markdowns
          path: /kpa/output/**.md
      - name: Upload pdf files
        uses: actions/upload-artifact@v3
        with:
          name: pdfs
          path: /kpa/output/**.pdf
```

Each step is self explaining, but to give some highlights:

- There's an overall environment variable definition, `KPA_PROJECT`, that will
  be used in all the jobs.
- The CI will be launched for each push operation (`on: [push]`).
- The kpa container image, `ghcr.io/mmul-it/kpa:v1.0.0` reports also the release
  and this is suggested in CI because releases are more stable.
- There are two main jobs that will check:
  - The yaml and markdown linter consistency (`lint`).
  - The Ansible playbook execution, that will generate the files (`generate`)
    and push them as artifacts into GitHub.
  Each step is dependent from the previous one and starts with `Link project dir
  in KPA projects folder`, a trick to put your project available in the
  `/kpa/projects` folder.

**Note**: this same repository uses GitHub actions to automatically lint the
Ansible code and the yaml and then produce slides and agenda for the default
`example` project, check [.github/workflows/main.yml](.github/workflows/main.yml).

**Note**: the KPA project was presented in several public occasions using a
presentation that is available at [https://github.com/mmul-it/kpa-mmul](https://github.com/mmul-it/kpa-mmul).
This KPA project includes [the GitHub Workflow pipeline](https://github.com/mmul-it/kpa-mmul/blob/main/.github/workflows/main.yml)
mentioned in the above code portion.

## Implement CI with GitLab CI

If your repository lives inside GitLab then this is a practical example about
how to use the KPA container to process a project named `myproject` using GitLab
CI.

A `.gitlab-ci.yml` yaml file should contain something like this:

```yaml
image:
  name: ghcr.io/mmul-it/kpa:v1.0.0
  entrypoint: [""]

variables:
  KPA_PROJECT: example

stages:
  - lint
  - generate

lint:
  stage: lint
  script:
    # YAML check
    - yamllint -s trainings/*.yml
    # Markdown check
    - mdl -c /kpa/.mdlrc contents/*/*.md

generate:
  stage: generate
  # Save generated markdown files
  artifacts:
    paths:
      - output/*.md
      - output/*.pdf
  script:
    # Create symlink in the /kpa/projects dir pointing to project dir
    - ln -vs ${CI_PROJECT_DIR} /kpa/projects/${KPA_PROJECT}
    # Generate markdown and pdf files
    - for AREA in trainings presentations; do
       echo "Processing area ${AREA}";
    - for KPA_DOC in $(cd /kpa/projects/${KPA_PROJECT}/; ls *.yml); do
        /kpa/kpa.sh -p ${KPA_PROJECT} -y ${KPA_DOC};
       done
      done
    # Move output folder into project dir (symlink won't work)
    - mv /kpa/output ${CI_PROJECT_DIR}/output
```

It uses the same trick of the symbolic link as the GitHub's one and it does
essentially the same three main steps, or stage as GitLab calls them.

This file will be placed into your project's GitLab repository and, for every
push, will look for every training or content yaml file definition and process
it into a pdf file under the `output` directory, making those files available as
GitLab job's artifacts.
