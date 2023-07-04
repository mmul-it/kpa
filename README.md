# ![KPA - The Knowledge Pods Approach](./images/kpa-github-header.png#gh-light-mode-only) ![KPA - The Knowledge Pods Approach](./images/kpa-github-header-dark.png#gh-dark-mode-only)

[![GitHub Actions CI](https://github.com/mmul-it/kpa/actions/workflows/main.yml/badge.svg?event=push)](https://github.com/mmul-it/kpa/actions/workflows/main.yml)
[![Docker Repository on Quay](https://quay.io/repository/mmul/kpa/status "Docker Repository on Quay")](https://quay.io/repository/mmul/kpa)

This repository defines the **Knowledge Pods Approach** (**KPA**), an agile way to create, maintain and evolve training materials and presentations using standard [Markdown](https://en.wikipedia.org/wiki/Markdown) files to create beautiful slide sets.

## What is a KPA project?

A **KPA project** is a set of variables and Markdown files that are used by the Ansible role named [kpa_generator](https://github.com/mmul-it/kpa_generator) to automate the creation of a single Markdown file that can be processed using [Marp (Markdown Presentation Ecosystem)](https://marp.app/#get-started) to obtain a set of slides in the usual presentation formats like **html**, **pdf** and **ppt**.

**KPA** makes it possible to control all the knowledge in a standard and "edit from everywhere" way, making it easy to compose and mix the set of topics you want to include into the training, by creating sequences of **Knowledge Pods** (**KP**).

## What is a Knowledge Pod?

A **Knowledge Pod** (**KP**) is the smallest part you can split a section of a training or of a presentation.

You can imagine it as a chapter. For example, if you need to deliver a training named "**How to use my technology**" in which you'll have to cover an **introduction** to your technology, the **prerequisites**, the **installation** and finally **day 0 operation**, then each one of these chapters would be a Knowledge Pod, like:

- *Introduction.md*

- *Prerequisites.md*

- *Installation.md*

- *Day-0-operations.md*

A **Knowledge Pod** should have, uniformly, the same duration (say one hour), so that it will be easy to compose a training by picking the needed KP.

Each section of a **Knowledge Pod**, say a paragraph, is separated from the other with the `---` Markdown element, which represents a new slide.

## What are the benefits of adopting KPA?

There are several benefits using KPA:

- **Concentrate <u>just</u> on the contents**: once you have defined your project, you don't need to care about anything but writing Knowledge Pods. No need to manually syntax highlight your code blocks, no need to adapt text, no need to duplicate your slide to modify just a simple sentence.
  Just write your Knowledge Pods in Markdown and you're good to go.

- **Compose training and presentations <u>dynamically</u>**: no more Power Point slides cut and paste. You can combine your Knowledge Pods in the way that fits your needs, creating as many variants of your training and presentations as you need.

- **Have the same look & feel for <u>every</u> training or presentation**: no more "*Ok, now you need to apply this new slide format to all our 100 presentations*". You will define your project look & feel one time and it will be applied everywhere, always the same way.

- **Use a <u>standard</u> and <u>reusable</u> format**: the same documentation you will produce with KPA could be used wherever you want because it's Markdown, which is a standard, and you will be able to write your own tool to manage your **Knowledge Pods**.

- **Keep everything versioned and <u>in order</u>**: once you'll store your KPA projects in a Git repository, you'll get versioning, monitoring of the changes and your entire knowledge in one traceable place.

- **Let everyone <u>do their job</u>**: Markdown is simple to the point that even non-technical people can edit Knowledge Pods and this allows for everyone to do their job: graphics can work on the themes, instructors can write the contents and you, the **KPA master ©**, will put everything together.

## Create a KPA project

After cloning this repository:

```bash
> git clone https://github.com/mmul-it/kpa.git
Cloning into 'kpa'...
remote: Enumerating objects: 125, done.
remote: Counting objects: 100% (125/125), done.
remote: Compressing objects: 100% (59/59), done.
remote: Total 125 (delta 51), reused 114 (delta 43), pack-reused 0
Receiving objects: 100% (125/125), 3.88 MiB | 3.38 MiB/s, done.
Resolving deltas: 100% (51/51), done.

> cd kpa
```

You'll see a `projects` directory, which is meant to contain all your KPA projects. You can use `example` project as your starting point.

This is the structure of a **KPA project**:

```console
projects/example/
├── common
│   ├── settings.yml
│   ├── example.tex
│   └── theme.css
├── images
│   ├── chapter-background.png
│   ├── cover-background.png
│   ├── logo.png
│   └── slide-background.png
├── templates
│   ├── chapter.md.j2
│   └── cover.md.j2
├── contents
│   ├── Topic-10.md
│   ├── ...
│   └── Topic-18.md
└── Example-Training-01.yml
```

Where:

- [common](projects/example/common): is the home for shared training/presentation files:
  
  - [theme.css](projects/example/common/theme.css) is the css theme file that overrides Marp's default theme. This is not needed, you can use a [predefined Marp theme](https://github.com/marp-team/marp-core/tree/main/themes).
  
  - [example.tex](projects/example/common/example.tex) is the Pandoc texfile template. This is not *strictly* needed, but to get the best from the generated agenda pdf a Pandoc template is more than reasonable.
  
  - [settings.yml](projects/example/common/settings.yml) **is mandatory** and contains the general presentation parameters that will override role's defaults:
    
    ```yaml
    ---
    
    kpa_project_dir: 'projects/example'
    
    pandoc_agenda_template_file: "{{ kpa_project_dir }}/common/example.tex"
    pandoc_agenda_background_image: "{{ kpa_project_dir }}/images/schedule-background.png"
    pandoc_agenda_header_includes:
      - '\usepackage{booktabs}'
      - '\usepackage{longtable}'
      - '\usepackage{array}'
      - '\usepackage{multirow}'
      - '\usepackage{wrapfig}'
      - '\usepackage{float}'
      - '\usepackage{colortbl}'
      - '\usepackage{pdflscape}'
      - '\usepackage{tabu}'
      - '\usepackage{threeparttable}'
      - '\usepackage{threeparttablex}'
      - '\usepackage[normalem]{ulem}'
      - '\usepackage{makecell}'
    
    marp_theme: example
    marp_theme_file: "{{ kpa_project_dir }}/common/theme.css"
    marp_background_color: #ffffff
    marp_background_image: "{{ kpa_project_dir }}/images/slide-background.png"
    marp_author: 'Raoul Scarazzini'
    marp_copyright: '© 2023 MiaMammaUsaLinux.org'
    marp_paginate: true
    
    marp_cover_template: "{{ kpa_project_dir }}/templates/cover.md.j2"
    marp_cover_image: "{{ kpa_project_dir }}/images/cover-image.png"
    marp_cover_logo: "{{ kpa_project_dir }}/images/logo.png"
    marp_cover_background_image: "{{ kpa_project_dir }}/images/cover-background.png"
    
    marp_chapter_template: "{{ kpa_project_dir }}/templates/chapter.md.j2"
    marp_chapter_background_image: "{{ kpa_project_dir }}/images/chapter-background.png"
    ```

- [images](projects/example/images/) contains backgrounds, logos and all the useful graphics elements for the slides.

- [templates](projects/example/templates/) contains the templates for the special slides that will be processed by Ansible. These templates will parse the variables, to be reusable. For example, the [chapter.md.j2](projects/example/templates/chapter.md.j2) contains the layout for the slide that will be shown at the beginning of each KP/Chapter:
  
  ```markdown
  ---
  
  <!-- _backgroundImage: url({{ marp_chapter_background_image }}) -->
  
  # <span class="txt-yellow">{{ slide.title }}</span>
  
  <span class="txt-yellow">{{ slide.chapter }}</span>
  ```
  
  The variables used in this file can be declared globally (like `marp_chapter_backgroundImage`, see [slides-settings.yml](projects/example/slides-settings.yml)) or specifically (like `slide.title`, see [Example-Training-01.yml](projects/example/Example-Training-01.yml)).

- [contents](projects/example/contents/) contains the **Knowledge Pods** in the [Marp Markdown compatible format](https://marpit.marp.app/markdown) (The main rule: `---` is the beginning of a new slide).

- [Example-Training-01.yml](projects/example/Example-Training-01.yml) is the slides set declaration, it contains the structure of the document, in a list element:
  
  ```yaml
  ---
  marp_title: "My spectacular course"
  
  output_file: "slides/Example-Training-01"
  schedule_output_file: "{{ output_file }}.schedule.md"
  marp_output_file: "{{ output_file }}.md"
  
  kpa_contents: "{{ kpa_project_dir }}/contents"
  
  marp_slides:
    # DAY 1
    - cover: true
      title: "{{ marp_title }}"
      subtitle: "DAY ONE"
    - chapter: 'DAY ONE - PART ONE'
      title: 'Topic 1'
      content: "{{ kpa_contents }}/Topic-1.md"
    - chapter: 'DAY ONE - PART TWO'
      title: 'Topic 2'
      content: "{{ kpa_contents }}/Topic-2.md"
      ...
      ...
    # Day 2
    - cover: true
      title: "{{ marp_title }}"
      subtitle: "DAY TWO"
    - chapter: 'DAY TWO - PART SEVEN'
      title: 'Topic 7'
      content: "{{ kpa_contents }}/Topic-7.md"
      ...
      ...
    # Day 3
    - cover: true
      title: "{{ marp_title }}"
      subtitle: "DAY THREE"
    - chapter: 'DAY THREE - PART THIRTEEN'
      title: 'Topic 13'
      content: "{{ kpa_contents }}/Topic-13.md"
      ...
      ...
    - chapter: 'DAY THREE - PART EIGHTEEN'
      title: 'Topic 18'
      content: "{{ kpa_contents }}/Topic-18.md"
  ```

## Using the KPA container

KPA comes with a handy container that can be used to automate the creation of both the slides and the agenda PDF files.

Once you have a local project in place:

```console
> ls -1
common
contents
Example-Training-01.yml
images
templates
```

You will need to launch the container by:

- Mapping the project directory as a volume inside the `/kpa/projects/<project name>` container's directory.

- Mapping the output directory (in this example `/tmp`) inside the `/kpa/output` container's directory.

- Pass the `--project <project name>` (in this example `example`) and `--yml <kpa document yaml>` (in this example `Example-Training-01.yml`) options.

Your command line will be something like this:

```console
> docker run --rm \
  -v $PWD:/kpa/projects/example \
  -v /tmp:/kpa/output \
  quay.io/mmul/kpa --project example --yml Example-Training-01.yml
```

After a really short time you should get:

```console
Rendering example KPA project for Example-Training-01.yml file -> Completed.
```

The output files will be created in the output mapped directory (in this example `/tmp`):

```console
> ls -1 /tmp/Example-Training-01.*
/tmp/Example-Training-01.agenda.md
/tmp/Example-Training-01.agenda.pdf
/tmp/Example-Training-01.md
/tmp/Example-Training-01.pdf
```

**Note**: in case of errors, it is possible to use the `-v|--verbose` option to get a more talkative output (in fact the `ansbile-playbook` output).

### Results

The KPA container execution should produce these set of slides and agenda inside the mapped output directory:

- Cover:
  
  ![images/slide-cover.png](images/slide-cover.png)

- Chapter:
  
  ![](images/slide-chapter.png)

- Slide:
  
  ![](images/slide.png)

- Agenda:
  
  ![](images/schedule.png)

### Using KPA manually and in CI

The KPA container can be used interactively, and will give you an environment with all the tools needed to generate both slides and agenda, but it is also possible to use the `kpa_generator` Ansible role locally. Check the [KPA manual commands](Commands.md) document to learn how to use the tools manually.

If you are interested in a deeper way of integrating KPA you can check the [Using KPA in CI](CI.md) document to understand how to use KPA in both GitHub and GitLab CI workloads.

## License

MIT

## Author Information

Raoul Scarazzini ([rascasoft](https://github.com/rascasoft))                    
