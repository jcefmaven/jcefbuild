<div id="title" align="center">
<h1>JCEF BUILD</h1>
<a href="../../releases/"><img alt="build-all" src="../../actions/workflows/build-all.yml/badge.svg"></img></a>

<h4>Independent project to produce binary artifacts for the jcef project</h4>
<h6>Visit the JCEF repo at <a href="https://bitbucket.org/chromiumembedded/java-cef/src/master/">bitbucket</a> or <a href="https://github.com/chromiumembedded/java-cef">github</a> </h6>

### Build Specs:

|               |Win i386 & amd64   |Win arm64          |Linux i386, amd64, arm & arm64|MacOS amd64 & arm64           |
|---------------|-------------------|-------------------|------------------------------|------------------------------|
|**Java**       |Oracle JDK 8       |Microsoft JDK 11   |OpenJDK 11                    |Temurin JDK 8                 |
|**Compiler**   |VS 2019            |VS 2019            |GCC 10                        |Xcode 12                      |
|**Build**      |Python 3.7; `ninja`|Python 3.7; `ninja`|Python 3.7; `ninja`           |Python 2.7; `ninja`; SDK 10.11|
|**Limitations**|-                  |No OSR mode        |-                             |Most likely needs a bundle    |

</div>

---

## Downloading artifacts
You can find the most recent versions of our artifacts on the releases page of this repository.

## Reporting bugs
Please only report bugs here that are related to the build process.
Please report bugs in JCEF/CEF to the JCEF repository on Bitbucket.

## Building your own projects
You have multiple options to build your own project using this repository. They are listed below.

### Building another git repo using GitHub Actions
To build another git repo, simply fork this repository. Then go to the "Actions" tab of your forked repository,
activate the workflows and manually run the `build-all` (or `build-<platform>`) workflow with your repository and commit id/branch specified.
This will trigger a build of your desired repository and platforms.

### Building locally
To build locally, put your sources in the `jcef` directory of this repository, or leave it empty to clone a repository.
On Windows and Linux, make sure you installed docker (NOT the Snap version!).
On MacOS, make sure you installed the build dependencies specified
[here](https://bitbucket.org/chromiumembedded/java-cef/wiki/BranchesAndBuilding) and `ninja`.

Then execute `compile-<os>.<sh|bat> <arch> <buildType> [<gitrepo> <gitref>]`.
Specify an architecture (docker architectures, see script source for options) and build type (Release or Debug).
Optionally, you can specify a git repository and ref/branch to pull when no sources are present in the `jcef` folder.

## Contributing
Feel free to open a pull request on this repository to improve its stability or artifact quality. Make sure to provide a valid GitHub Actions run for your pull requests to be accepted.
