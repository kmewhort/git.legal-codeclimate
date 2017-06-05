# Git.legal - CodeClimate Community Edition

Git.legal scans the libraries used by your project and flags potential compliance and compatibility issues, optionally
based on policies that you configure.

## Supported languages and package managers

The community edition of Git.legal currently only supports analysis of ruby libraries - but expect wider support *very*
soon!  For analysis supporting Bower, NPM, Go, Maven, javascript includes, please try https://git.legal.

## Installation

1. This version of Git.legal is designed to run through CodeClimate -- please visit https://codeclimate.com/ to get started.

2. Once you have your project setup for analysis through CodeClimate, add the following to the `engines` section of your
`.codeclimate.yml` file:

```
 git.legal:
    enabled: true
```

3. Ensure that your `Gemfile.lock` is checked into source control.

4. Run an analysis on CodeClimate!

## License Policy Configuration

You can add a configurations section to your `.codeclimate.yml` to set which types of licenses you wish to allow and
disallow for your project.  For example, the example below (which is the default setting), is a typical policy to only
exclude "strong copyleft" and Affero licenses:

```
 git.legal:
    enabled: true
    config:
      allow_affero_copyleft:   false
      allow_strong_copyleft:   false
      allow_weak_copyleft:     false
      allow_permissive:        true
      allow_unknown_libraries: true
```

## License

This project is available as open source under the terms of the
[GNU Affero General Public License 3.0](https://www.gnu.org/licenses/agpl-3.0.en.html), or by explicit permission of
the author.

