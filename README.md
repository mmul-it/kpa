# KPA - The Knowledge Pods Approach

This repository defines the **Knowledge Pods Approach** (**KPA**), an agile way to create, maintain and evolve training materials using [Markdown]([Markdown - Wikipedia](https://en.wikipedia.org/wiki/Markdown)) files to create beautiful slide sets.

## How does it work?

A **KPA project** is composed by a set of variables and contents that are used by the Ansible role named `marp-slides-creator`, which automates the creation of a Markdown file that can be processed using [Marp (Markdown Presentation Ecosystem)](https://marp.app/#get-started) to obtain a set of slides in the usual presentation formats like **html**, **pdf** and **ppt**.

**KPA** makes it possible to control all the knowledge in a standard and "edit from everywhere" way, making it easy to compose the set of topics you want to include into the training, by creating sequences of **Knowledge Pods** (**KP**).

### What is a Knowledge Pod?

A **Knowledge Pod** (**KP**) is the smallest part you can split a section of a training.

You can imagine it as a chapter. For example, if you need to deliver a training named "**How to use my technology**" in which you'll have to cover an **introduction** to your technology, the **prerequisites**, the **installation** and finally **day 0 operation**, then each one of these chapters would be a Knowledge Pod, like:

- *Introduction.md*

- *Prerequisites.md*

- *Installation.md*

- *Day-0-operations.md*

A **Knowledge Pod** should have, uniformly, the same duration (say one hour), so that it will be easy to compose a training by picking the needed KP.

## How to create a KPA project

Even if using the [Marp - Markdown Presentation Ecosystem](https://marp.app/#get-started) is quite simple, keeping things clean and ordered can become tricky, particularly when there's a lot of material to work on.

The `marp-slides-creator` Ansible role takes a **KPA project** directory and automates the creation of the Marp compatible markdown file that will be used by the tool to generate the slides.

The structure of a **KPA project** directory would be like this:

```console
example/
├── contents
│   ├── Topic-1.md
│   ├── Topic-2.md
│   ...
│   └── Topic-18.md
├── images
│   ├── cover-background.png
│   ├── ...
│   └── logo.png
├── templates
│   ├── chapter.md.j2
│   └── cover.md.j2
├── Example-Training-01.yml
├── slides-settings.yml
└── theme.css
```

Where:

- [contents](example/contents/) contains the **Knowledge Pods** in the [Marp Markdown compatible format](https://marpit.marp.app/markdown) (i.e. `---` is the beginning of a new slide).

- [images](example/images/) contains backgrounds, logos and all the useful graphics elements for the slides.

- [templates](example/templates/) contains the templates for the special slides that will be processed by Ansible. These templates will parse the variables, to be reusable. For example, the [chapter.md.j2](example/templates/chapter.md.j2) contains the layout for the slide that will be shown at the beginning of each KP/Chapter:
  
  ```markdown
  ---
  
  <!-- _backgroundImage: url({{ marp_chapter_backgroundImage }}) -->
  
  # <span class="txt-yellow">{{ slide.title }}</span>
  
  <span class="txt-yellow">{{ slide.chapter }}</span>
  ```
  
  The variables used in this file can be declared globally (like `marp_chapter_backgroundImage`, see [slides-settings.yml](example/slides-settings.yml)) or specifically (like `slide.title`, see [Example-Training-01.yml](example/Example-Training-01.yml)).

- [Example-Training-01.yml](example/Example-Training-01.yml) is the slides set declaration, it contains the structure of the document, in a list element:
  
  ```yaml
  ---
  marp_title: "My spectacular course"
  
  marp_slides:
    # Day one
    - cover: true
      title: "{{ marp_title }} - DAY 1"
      subtitle: "DAY ONE"
    - chapter: 'DAY ONE - PART ONE'
      title: 'Topic 1'
      content: 'example/contents/Topic-1.md'
    - chapter: 'DAY ONE - PART TWO'
      title: 'Topic 2'
      content: 'example/contents/Topic-2.md'
      ...
      ...
    # Day two
    - cover: true
      title: "{{ marp_title }} - DAY 2"
      subtitle: "DAY TWO"
    - chapter: 'DAY TWO - PART SEVEN'
      title: 'Topic 7'
      content: 'example/contents/Topic-7.md'
      ...
      ...
    # Day three
    - cover: true
      title: "{{ marp_title }} - DAY 3"
      subtitle: "DAY THREE"
    - chapter: 'DAY THREE - PART THIRTEEN'
      title: 'Topic 13'
      content: 'example/contents/Topic-13.md'
      ...
      ...
    - chapter: 'DAY THREE - PART THIRTEEN'
      title: 'Topic 18'
      content: 'example/contents/Topic-18.md'
  ```

- [slides-settings.yml](example/slides-settings.yml) contains the general presentation parameters that will override role's defaults:
  
  ```yaml
  ---
  
  marp_theme: example
  marp_backgroundColor: #ffffff
  marp_backgroundImage: 'example/images/slide-background.png'
  marp_author: 'Raoul Scarazzini'
  marp_copyright: '© 2023 MiaMammaUsaLinux.org'
  marp_paginate: true
  
  marp_cover_template: 'example/templates/cover.md.j2'
  marp_cover_image: 'example/images/cover-image.png'
  marp_cover_logo: 'example/images/logo.png'
  marp_cover_backgroundImage: 'example/images/cover-background.png'
  
  marp_chapter_template: 'example/templates/chapter.md.j2'
  marp_chapter_backgroundImage: 'example/images/chapter-background.png'
  ```

- [theme.css](example/theme.css) is the css theme file that overrides Marp's default theme. This is not needed, if you want to use a [predefined Marp theme]([marp-core/themes at main · marp-team/marp-core · GitHub](https://github.com/marp-team/marp-core/tree/main/themes)).

Once everything is in place it is time to execute, via `ansible-playbook` command the Ansible playbook named `marp-slides-creator.yml`, passing the **KPA Project** variables related to the general slides settings (`-e @example/slides-settings.yml`) and to the specific training (`-e @example/Example-Training-01.yml`) :

```console
> ansible-playbook -e @example/slides-settings.yml -e @example/Example-Training-01.yml marp-slides-creator.yml
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [localhost] *********************************************************************************************************************************************************

TASK [marp-slides-creator : Creating the template] ***********************************************************************************************************************
changed: [localhost]

PLAY RECAP ***************************************************************************************************************************************************************
localhost                  : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

This command will generate a file named `slides.md` in the `slides` directory, as declared in the `marp_output_file` variable (see [roles/marp-slides-creator/defaults/main.yml](roles/marp-slides-creator/defaults/main.yml)).

## Working with Markdown Marp files

To get a presentation with the Markdown file generated by the `marp-slides-creator` Ansible role you can use the [Marp container](https://hub.docker.com/r/marpteam/marp-cli), like this:

```console
> docker run --rm -e MARP_USER=$(id -u):$(id -g) \
  -v $PWD:/home/marp/app/ -e LANG=$LANG \
  marpteam/marp-cli --html true --theme ./example/theme.css slides/slides.md 
[  INFO ] Converting 1 markdown...
[  INFO ] slides/slides.md => slides/slides.html
```

`Marp` supports exporting in `pdf`, `html` and `ppt`, you might want to remember the `--allow-local-files` when exporting into static files like `pdf` and `ppt`.

### Themes

For the Example training a custom css (check [example/theme.css](example/theme.css)) has been created to reflect the company look & feel.

This can be integrated with the various tools available for Marp:

- [Marp for VS Code extension](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode): In the `settings.json` file
  
  ```json
  {
    "markdown.marp.themes": ["./example/theme.css"],
    "markdown.marp.enableHtml": true
  }
  ```

- With the [Marp CLI](https://github.com/marp-team/marp-cli)
  
  ```bash
  marp --pdf --theme example/theme.css --html true --allow-local-files Example-Training-01.md
  ```
