---
title: "Deploying a Hugo blog to GitHub"
date: 2020-11-29T15:43:24Z
tags: ["github", "hugo"]
---

How to deploy a Hugo site to GitHub Pages using a single repository.
<!--more-->

Deploying a Hugo site to Github Pages can be a good choice when you're you want some control over look and feel but aren't interested in sorting out the whole caboodle.

As with most things I tried to base this on existing tutorials/examples. Almost all the examples I came across suggested that you *must* use two git repositories for it to work.

This guide covers the approach I went with which uses a single git repository to hold both the Hugo project and the compiled site. The advantages for me were:

* Everything all in one place
* Not having to deal with git changes submodules for the public site (which felt noisy)

## Pre-requisites

* Git
* Hugo (I'm using 0.78)

## Hugo overview

If you're here you probably already know that Hugo is a static site generator that allows you to build a site with Markdown files.

`hugo new site [name]` creates a directory called `[name]` with the following structure:

```bash
|- archetypes
|- content
|       Your site content as markdown files
|- data
|- layout
|- resources
|- static
|       Any static content / assets that you want to place on your site
|- themes
|       Installed themes
|- config.yml
```

Most of what we'll do to get set up will involve the themes directory and config.yml

## Theme installation

There are [tons of themes](https://themes.gohugo.io/) to choose from for Hugo and once you have picked something to suit your tastes you'll need to get the code for the theme into the `thmmes` directory for your site to install it.

There are three options for installation:

* Download the theme files and copy them into themes
* Clone the repository into themes
* Add the repository as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

Git submodule offered the possibility of being able to pull any updates/bug fixes that are made to the theme without needing to manually download and unpack the archive.


I chose the beautifulhugo theme so did the following to install the theme. Obviously replace the git URL with whatever you choose...

```bash
cd themes/
git submodule add git@github.com:halogenica/beautifulhugo.git
```

### Site Configuration

Once the theme code is in place we need to update our site config. To do this I added the following configuration near the top of the file:

```yaml

...
theme: beautifulhugo
...

```

### Example site

I found documentation of the various options hard to come by for many themes I looked at. The easiest way to work out what options are available for this theme are to check out the example site in the theme code.

The example site (if there is one), can be found at `themes/beautifulhugo/exampleSite` and the config in particular is a very helpful starting place.

## Configuration

As well as setting up site title, author name and language codes there are a few other configuration changes I made for `beautifulhugo`.

### Markup style

```yaml
markup:
  highlight:
    codeFences: true
    guessSyntax: false
    lineNoStart: 1
    lineNos: true
    lineNumbersInTable: true
    style: "dracula"
```

These settings choose a highlighting style, use line numbers and put the line numbers in a table. Having the line numbers in a table keeps the code and the line numbers separate which is convenient for copying a code snippet.

### Author parameters

```yaml
author:
  name: Rocco Cammisola
  profile: ""
  github: "USERNAME"
  twitter: "USERNAME"
```

The `beautifulhugo` theme has a load of possible social media icons that you can switch on by configuring with a URL / Username. Unfortunately the way these are configured isn't the same for all themes.

## Publish Directory

When you build your Hugo site the compiled content (HTML, CSS, JS, Images) will be stored in `public` by default. In order to be able to publish the blog from a single repository you will need to set `publishDir` to `docs` in your config file.

```yaml
publishDir: "docs"
```

## Build site

### Local server with auto-reload

```bash
hugo server -D
```

You should be able to visit the site at `http://localhost:1313/`. The `-D` makes any draft posts appear as though they were published.

The compiled content doesn't appear to be saved when you run this local server.

### Generate static content

You will need to generate/compile the static site for there to be anything to serve from GitHub.

```bash
hugo -t beautifulhugo --minify
```

### Makefile

To make life easier for myself I've put the above into a Makefile so that I can run `make server|blog|deploy` without having to know the full command.

The makefile has these three directives in there currently:


```Makefile
msg="Updated blog"

blog:
	hugo -t beautifulhugo --minify

server:
	hugo -D server

deploy: blog
	git add .
	git commit -m "$(msg)"
	git push
```

The `msg` for the `deploy` directive can be passed in as a parameter with `make deploy msg="Published article on bees"`

## Github repository

We're finally ready to setup our github repository so that the site will be published.

1. Create a repository named `[USERNAME].github.io`
1. Add the remote origin to your local repository `git remote set-url origin REPO_URL`
1. In the repository settings under "Github Pages":
    1. Use None or Branch drop-down menu to select a publishing source
    1. Use the drop-down menu to select `/docs`
1. `git push origin master`

Provided that you've built and committed the site in docs, after a short amount of time you should see your site at the URL `[USERNAME].github.io`

You're now free to fill the site with content!

### References:

* https://levelup.gitconnected.com/build-a-personal-website-with-github-pages-and-hugo-6c68592204c7
