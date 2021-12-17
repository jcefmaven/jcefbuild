<div id="title" align="center">
<h1>JCEF BUILD</h1>
<a href="../../releases/latest"><img alt="build-all" src="../../actions/workflows/build-all.yml/badge.svg"></img></a>

<h4>Independent project to produce binary artifacts for the JCef project</h4>
<h6>Visit the JCEF repo at <a href="https://bitbucket.org/chromiumembedded/java-cef/src/master/">bitbucket</a> or <a href="https://github.com/chromiumembedded/java-cef">github</a> </h6>

<h6>Consider using these builds with Maven or Gradle: <a href="https://github.com/jcefmaven/jcefmaven">jcefmaven</a></h6>

### Build Specs:

<table>
  <tr>
    <td width="12%"></td>
    <td width="22%"><a href="#"><img src="https://simpleicons.org/icons/linux.svg" alt="linux" width="32" height="32"></a><br/><b>amd64, arm64, i386 & arm</b></td>
    <td width="22%"><a href="#"><img src="https://simpleicons.org/icons/windows.svg" alt="windows" width="32" height="32"></a><br/><b>amd64 & i386</b></td>
    <td width="22%"><a href="#"><img src="https://simpleicons.org/icons/windows.svg" alt="windows" width="32" height="32"></a><br/><b>arm64</b></td>
    <td width="22%"><a href="#"><img src="https://simpleicons.org/icons/apple.svg" alt="apple" width="32" height="32"></a><br/><b>amd64 & arm64</b></td>
  </tr>
  <tr>
    <td><b>Java</b></td>
    <td>OpenJDK 11</td>
    <td>Oracle JDK 8</td>
    <td>Microsoft JDK 11</td>
    <td>Temurin JDK 8</td>
  </tr>
  <tr>
    <td><b>Compiler</b></td>
    <td>GCC 10</td>
    <td>VS 2019</td>
    <td>VS 2019</td>
    <td>Xcode 12</td>
  </tr>
  <tr>
    <td><b>Build</b></td>
    <td>Python 3.7; <code>ninja</code></td>
    <td>Python 3.7; <code>ninja</code></td>
    <td>Python 3.7; <code>ninja</code></td>
    <td>Python 2.7; <code>ninja</code>; SDK10.11</td>
  </tr>
  <tr>
    <td><b>Limitations</b></td>
    <td>-</td>
    <td>-</td>
    <td>No OSR mode (no Jogamp)</td>
    <td>Needs <a href="https://bitbucket.org/chromiumembedded/java-cef/issues/109/">custom structure</a> to run outside of a bundle</td>
  </tr>
</table>

</div>

---

## Downloading artifacts
You can find the most recent versions of the artifacts on the [releases](../../releases) page of this repository.

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

## Reporting bugs
Please only report bugs here that are related to the build process.
Please report bugs in JCEF/CEF to the [corresponding repository on Bitbucket](https://bitbucket.org/chromiumembedded/).

## Contributing
Feel free to open a pull request on this repository to improve its stability or artifact quality. Make sure to provide a valid GitHub Actions run for your pull requests to be accepted.

