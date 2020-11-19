# Hello!

The purpose of this document is to get you started with a combination of nasher and git in order to start version controlling your NWN module and allow you to build new module files on-demand.  This guide is written for those with some programming and/or command-line experience.  Because of this, many notes and lesser errors are not included as it is assumed you can resolve them.  If that is not the case, feel free to [contact us](#questions) and we'll try to help resolve your issue.

Current as of: 0.11.7

* Quick Start
    * [Install Git](#git)
    * [Install Nasher](#nasher)
    * [Unpack Your Module File](#unpacking)
* [Nasher Project Configuration](#nasher-project-configuration)
* [Nasher Commands](#nasher-commands)
    * [Global Arguments](#arguments)
    * [Configuration](#config)
    * [Convert](#convert)
    * [Compile](#compile)
    * [Pack](#pack)
    * [Install](#install)
    * [Launch](#launch)
* [Docker](#docker)
* [Errors](#errors)
* [Troubleshooting](#troubleshooting)
* [Frequently Asked Questions](#faq)
* [Help](#help)

## Git
---
While there are several source control providers available, GitHub is one of the most common.  It's free, full-featured and easy to use.  This document will refer to methodology used by GitHub.  If you use GitLab or other providers, it may differ.  A source-control provider is not required to use nasher.

1. Go to the GitHub [join page](https://github.com/join).
2. Complete the registration process.
3. Remember your username and password, you'll need this when you install and setup Git.
4. Go to [github.com](https://github.com) and login.  You will be taken to your homepage.  In the top left corner, underneath the search bar, there should be a big green button labeled `New`.  Click on this to create a new repository for your module.  Choose any name you like, but DON'T USE SPACES IN YOUR REPO NAME.  We're big fans of public repositories, but feel free to make yours private if you wish.  **Do not** click on the checkbox that's labeled `Initialize this repository with a README`.  Click on the big green `Create Repository` button to create your first repository.  It's empty for now, but we'll populate it later

#### Git
In order to efficiently maintain and update your module repo, you need a git client.  Git is source control software which tracks changes to selected code and allows reversion, if necessary.  Following are the steps to obtain, install and configure your git client.  For those on Windows, you will get a tool called Git Bash which is a version of PowerShell or a command line utility.  However, any command line utility or terminal can be used to accomplish the tasks required to setup Git.

1. [Download](https://git-scm.com/downloads) and install git for your operating system.
2. Add your username and e-mail to the Git configuration file.  This is required if you want to submit content to the repository.  This not the user name you used to [create an account on GitHub](#github-account) in the previous section.  It's just your name.  This value and your email will be automatically attached to all commits that are pushed to the remote repository.  In your command line client, type the following:

    ```
    git config --global user.name "<your name>"
    git config --global user.email "<your.email@address.com>"
    ```
[Table of Contents](#hello!)
## Nasher
---
Nasher is a command-line tool that uses and extends [Neverwinter Tools](https://github.com/niv/neverwinter.nim) to unpack, pack, compile and test modules ... really, it's just a great all-around tool that makes a module builder's life much easier.  There are few prerequisites to installing Nasher natively.  Nasher can be run via Docker, but it's much easier and more convenient to run it natively.  If you do not want to install [nimble](#nimble), [neverwinter](#neverwinter) and [nasher](#nasher) onto your machine, there is a [docker option](#docker).

#### Nimble
Nimble is a package manager for the Nim programming language.  Although you will probably only directly use this once during this setup, it is a pre-requistie for installing Nasher.

1. Install choosenim to make installing nimble exceptionally easy.  Go to the [choosenim releases page](https://github.com/dom96/choosenim/releases) and download the appropriate release for your operating system.  If you selected a zipped file, unzip the files to your preferred location (they cannot be run directly from the zip file) and run the `runme.bat` batch file.  This will install choosenim and add the nimble directory to your system PATH variable.

    *Note:  If you receive an error in the next section that says nimble is not a known command (or something similar), it is because the path to nimble wasn't added to your system's path variable.*

#### Neverwinter
Neverwinter.nim is a set of tools that can convert the various file formats used by Neverwinter Nights into `.json` and other formats, which are text files readable by most text readers and easily handled by source control systems such as Git.  Without these conversion tools, we would not be able to track file changes nor have the convenience of build tools such as Nasher.

Since we've already installed Nimble, installing neverwinter.nim is extremely easy.

1. In your command line utility:
    ```
    nimble install neverwinter
    ```

#### Nasher
Since we already have the nimble programming language installed via choosenim, installing Nasher is easy. 

1. In your command line utility, type:
    ```
    nimble install nasher
    ```
2. After installation, you can verify the version:
    ```
    nasher -v
    ```
3. Obtain and configure NWNSC.  NWNSC is an external script compiler for Neverwinter Nights.  A zip containing the nwnsc.exe file can be downloaded from [nwneetools nwnsc](https://github.com/nwneetools/nwnsc/releases).  Extract the file to your preferred location.  You'll tell Nasher where it is in the next steps.  

    NWNSC requires game binaries to function correctly.  The following command uses the path where your NWNEE game files are installed, not the path to the user content that is normally in your documents directory.  To configure your installation path, type ***one*** of the two following commands into your command line utility (read both, then choose your own adventure):

    If your folder names do not have spaces in them (good job!):
    ```c
    nasher config --nssFlags:"-n C:/<path>/<to>/<NWNEE> -owkey"
    ```
    *Note:  A common error is to have a trailing '/' after the path in the command above.  There should be no trailing '/'.  Additionally, the slants need to be forward, not back.*

    If your folder names have spaces in them (boooooooooooo!), you'll need to escape the entire path with double quotes:
    ```c
    nasher config --nssFlags:"-n \"C:/<path>/<to>/Neverwinter Nights\" -owkey"
    ```
    *Note:  In the second example above, the entire path is contained within escaped quotation marks.  You do not need to escape each individual space in the path.  The `-owkey` are nwnsc command line arguments, if you want to use different ones, insert them instead of `-owkey`.  NWNSC command line argument can also, optionally, be passed through the nasher.cfg file.*

    Now tell Nasher where you put the compiler (nwnsc.exe).  The backslashes must be escaped, so your command will look like this:
    ```c
    nasher config --nssCompiler:"C:\\Users\\<username>\\Desktop\\Git_Repositories\\ds\\nwnsc.exe"
    ```
    *Note:  You must include the full path to the compiler and the file name nwnsc.exe.*

## Unpacking
Before unpacking your module for the first time, create a folder that will eventually be used as the local git repository.  Call it whatever you want; avoid spaces.  In the examples below, we have created a repository folder called `myModule` with an absolute path of `C:/Users/<user>/Desktop/Git_Repositories/myModule`.

1. Create a nasher project within your repository folder (the one you just created).  In your CLI, in your `myModule` folder, type the following:
    ```c
    nasher init --default
    ```
    You can leave the `--default` off, but using defaults makes the process go faster and you can change default values within the `nasher.cfg` folder whenever you want.
2. Copy your module's `.mod` file into your `myModule` folder.
3. Unpack your module into a basic directory structure.  In your CLI, type the following:
    ```c
    nasher unpack --file:<mymodulename>.mod
    ```
    This command will convert all of your module resources into `.json` files and save them in a basic directory structure.  Once the unpacking process is complete, there should be a new folder in your `myModule` folder called `src`.  Within that folder, you'll find all of your converted module resources.  Scripts (`.nss`) files are not converted because they are plain text files.  You can edit any of these `.json` files in place, but it is not recommended.

    You are not limited to this directory structure.  You can organize your module any way you'd like and with any folder structure you'd like, you simply need to tell nasher where the files are via settings within `nasher.cfg`.  We'll go over that [later](#nasher-configuration-file).
4. Once you're happy with your directory structure, push everything into a git repository.
    ```c
    git add .
    git commit -m "initial commit"
    git remote add origin https://github.com/<your_user_name>/<your_repo_name>`
    git push -u origin master
    ```
5. Sit back, relax, and GET TO WORK!  You now have a fully source-controlled module.  From here on out, the `.mod` module file is no longer sacred.  You can build a new one at-will from the files within the new folder you created or from your remote repository that you just pushed your files to, so you can work from anywhere or collaborate with anyone.

[Table of Contents](#hello!)

---
## Nasher Project Configuration
---
---
This section discusses the capabilities and limitations of the nasher.cfg file, which should reside in the project's root directory.

#### Components
**[Package]** - an optional section, [Package] provides a location to codify a project's author, description, name, version and url.  This data is currently not used by any current nasher commands, but that may change in the future.

|Key|Description|
|---|---|
|`name`|package/project name|
|`description`|package/project description; """triple quotes""" enables multi-line descriptions|
|`version`|package/project version|
|`author`|name/email of the author; this field is repeatable|
|`url`|web location where the package/project can be downloaded|

**[Sources]** - an optional section, [Sources] describes the locations of all source files to be either included or excluded from a project.  This section uses [glob pattern](https://en.wikipedia.org/wiki/Glob_(programming)) matching to identify desired files.  If you do not include any sources in this section, you must include them in the [Target] section or Nasher will not have any files to work with.

|Key|Description|
|---|---|
|`include`|glob pattern matching files to include; this key is repeatable|
|`exclude`|glob pattern matching files to exclude; this key is repeatable|
|`filter`|glob pattern matching files to be included for compilation, but excluded from the module file/folder; this field can be repeated|
|`flags`|command line arguments to send to NWNSC at compile-time.|

**[Rules]** - an optional section, [Rules] defines a directory structure for extracted files.  During the unpacking processing, these rules will be evaluated, in order, to determine which location a specific file should be unpacked to.  [Rules] take the form `"pattern" = "path"`.  All paths are relative to the root folder.  These rules apply to any unpacked files that do not exist in the source tree (your `myModule` folder).  If there is no catch-all rule (`"*" = "path"`), indeterminate files will be placed in a file called `unknown`.

**[Target]** - a required section, at least one [Target] must be specified.  This section provides a target name, description, output file name and source list.

|Key|Description|
|---|---|
|`name`|name of the target; must be unique among [Target]s|
|`file`|name of the file to be created including extension; a path can be included to save the packed file into a specific directory, otherwise the file will be packed in the project root folder|
|`description`|an optional field that describes the target|
|`include`|glob pattern matching files to include; this key is repeatable; if used, only files matching target `include` values will be used and the [Sources] section will be ignored|
|`exclude`|glob pattern matching fiels to exclude; this key is repeatable; if used, only files matching target `exclude` values will be used and the [Sources] section will be ignored|
|`filter`|glob pattern matching files to be included for compilation, but excluded from the final target file; this key is repeatable; if used, only files matching target `filter` values will be used and the [Sources] section will be ignored|
|`flags`|command line arguments to send to NWNSC at compile-time|
|`[Rules]`|`"pattern" = "path"` entries, similar to the [Rules] section; these entries will only apply to this target|

[Table of Contents](#hello!)

---
## Nasher Commands
---
---
### Arguments
You can use the following arguments with most nasher commands:
```
-h, --help      <-- displays help for nasher or a specific command
-v, --version   <-- displays the nasher version
    --debug     <-- enable debug logging
    --verbose   <-- increases the feedback verbosity, useful for debugging
    --quiet     <-- disable all logging except errors
    --no-color  <-- disable color output
```

### Config
Gets, sets, or unsets user-defined configuration options. These options can be local (package-specific) or global (across all packages). Regardless, they override default nasher settings.

Nasher uses three sources for configuration data.  A global `user.cfg` (stored  in %APPDATA%\nasher\user.cfg on Windows or in $XDG_CONFIG/nasher/user.cfg on Linux and Mac), a local `user.cfg` (stored in .nasher/user.cfg in the package root directory) and the command-line.  Command-line options take precedence over the local configuration values, and local configuration values take precedence over the global configuration values.  Local configuration files will be ignored by git unless the `-vsc:none` flag used on `nasher init`.

Available Configuration Keys:
|Key|Default|Description|
|---|---|---|
|userName|git user.name|The default name to add to the author section of new packages|
|userEmail|git user.email|The default email use for the author section of new packages|
|nssCompiler|project root path| The path to the script compiler|
|nssFlags|-loqey|The [flags](#nwnsc-flags) to send to nwnsc.exe for compiling scripts|
|nssChunks|500|The maximum number of scripts to process at one time|
|erfUtil|nwn_erf.exe|the path to the erf pack/unpack utility|
|erfFlags||Flags to pass to erfUtil|
|gffUtil|nwn_gff.exe|the path to the gff conversion utility|
|gffFlags||Flags to pass to gffUtil|
|gffFormat|json|the format to use to store gff files|
|tlkUtil|nwn_gff.exe|the path to the tlk conversion utility|
|tlkFlags||Flags to pass to tlkUtil|
|tlkFormat|json|the format to use to store tlk files|
|installDir|Win: `~/Documents/Neverwinter Nights`|NWN user directory where built files should be installed|
||Linux: `~.local/share/Neverwinter Nights`||
|gameBin||path to nwnmain binary (only needed if not using steam)|
|serverBin||path to the nwserver binary (only needed if not using steam)|
|vcs|git|version control system to use for new packages|
|removeUnusedAreas|true|if `true`, prevents area not present in sources files from being referenced in `module.ifo`|
|||set to `false` if there are module areas in a hak or override|
|useModuleFolder|true|whether to use a subdirectory in the `modules` folder to store unpacked module files|
|||only used by NWN:EE|
|truncateFloats|4|maximum number of decimal places to allow after floats in gff files|
|||prevents unneeded file updates due to insignificant float value changes|

Command Line Options
|Argument|Description|
|---|---|
|`--global`|applies to all packages (default)|
|`--local`|applies to the current package only|
|`--get`|display the value of `<key>` (default if `<value>` not passed)|
|`--set`|set `<key>` to `<value>` (default when `<value>` passed)|
|`--unset`|deletes key/value pair for `<key>`|
|`--list`|lists all key/value pairs in the specified configuration file|

Usage:
```c
nasher config [options] --<key>:"<value>"
```
Examples
```c
nasher config --nssFlags:"-n /opts/nwn -owkey"
nasher config --local --nssCompiler:"C:\\Users\\<username>\\Desktop\\Git Repositories\\nwnsc.exe"
nasher config --installDir:"C:\\Users\\<username>\\Documents\\Neverwinter Nights"
```

### Unpack
Unpacks a file into the project source tree for the given target.

If a target is not specified, the first target found in nasher.cfg is used. If a file is not specified, Nasher will search for the target's file in the NWN install directory.

Each extracted file is checked against the target's source tree (as defined in the [Target] section of the package config). If the file only exists in one location, it is copied there, overwriting the existing file. If the file exists in multiple folders, you will be prompted to select where it should be copied.

If the extracted file does not exist in the source tree already, it is checked against each pattern listed in the [Rules] section of the package config. If a match is found, the file is copied to that location.

If, after checking the source tree and rules, a suitable location has not been found, the file is copied into a folder in the project root called `"unknown"` so you can manually move it later.

If an unpacked source would overwrite an existing source, its `sha1` checksum is checked against that from the last pack/unpack operation. If the sum is different, the file has changed. If the source file has not been updated since the last pack or unpack, the source file will be overwritten by the unpacked file. Otherwise you will be prompted to overwrite the source file. The default answer is to keep the existing source file.

Command Line Options
|Argument|Description|
|---|---|
|`--file`|the file to unpack into the target's source tree|
|`--yes`|automatically answers yes to all prompts|
|`--no`|automatically answers no to all prompts|
|`--default`|automatically accepts the default answer for all prompts|

Usage
```c
nasher unpack [options] [<target> [<file>]]
```

Examples
```c
nasher unpack myNWNServer --file:myModule.mod
```

### Convert
Converts all JSON sources for `<target>` into their GFF counterparts. If not supplied, `<target>` will default to the first target found in the package file.  The input and output files are placed in `.nasher/cache/<target>`.  Multiple `<target>`s may be specified, separated by spaces.  `<target>` may be the name of the target in `nasher.cfg`, a filename or a directory.

Command Line Options
|Argument|Description|
|---|---|
|`--clean`|clears the cache before packing|

Usage
```c
nasher convert [options] [<target>...]
```

Examples:
```c
nasher convert                                   <-- converts using first target in nasher.cfg
nasher convert default                           <-- converts using target named "default" in nasher.cfg
nasher convert --file:<path>                     <-- converts a specified directory using the default target in nasher.cfg
nasher convert <target> --file:<path>/<filename> <-- converts a specific file using the target in nasher.cfg
```

### Compile
Compiles all nss sources for `<target>`. If `<target>` is not supplied, the first target supplied by the config files will be compiled. The input and output files are placed in `.nasher/cache/<target>`.  NWNSC.exe is used as the compiler and compilation errors will be displayed with reference to filename, line number and general error description.  Default behavior is to place all compiled `.ncs` files into the cache folder associated with the specified target.  Will only compile `.nss` files that contain either a `void main()` or `int StartingConditional()` function as the rest are assumed to be includes.

Command Line Options
|Argument|Description|
|---|---|
|`--clean`|clears the cache before packing|
|`-f`, `--file`|compiles specific file, multiple files can be specified|

Usage
```c
nasher compile [options] [<target>...]
```

Examples:
```c
nasher compile                                   <-- compiles using first target in nasher.cfg
nasher convert default                           <-- compiles using target named "default" in nasher.cfg
nasher convert --file:<path>                     <-- compiles a specified directory using the default target in nasher.cfg
nasher convert <target> --file:<path>/<filename> <-- compiles a specific file using the target in nasher.cfg
```

### Pack
[Converts](#convert), [compiles](#compile), and packs all sources for `<target>`. If `<target>` is not supplied, the first target supplied by the config files will be packed. The assembled files are placed in `$PKG_ROOT/.nasher/cache/<target>`, but the packed file is placed in `$PKG_ROOT`.

If the packed file would overwrite an existing file, you will be prompted to overwrite the file. The newly packaged file will have a modification time equal to the modification time of the newest source file. If the packed file is older than the existing file, the default is to keep the existing file.

Command Line Options
|Argument|Description|
|---|---|
|`--clean`|clears the cache before packing|
|`--yes`|automatically answers yes to all prompts|
|`--no`|automatically answers no to all prompts|
|`--default`|automatically accepts the default answer for all prompts|

Usage
```c
nasher pack [options] [<target>...]
```

Examples:
```c
nasher pack                  <-- packs using first target in nasher.cfg
nasher pack <target> --yes   <-- packs using <target> in nasher.cfg and answers all prompt `yes`
```

### Install
[Converts](#convert), [compiles](#compile), and [packs](#pack) all sources for `<target>`, then installs the packed file into the NWN installation directory. If `<target>` is not supplied, the first target found in the package will be packed and installed.

If the file to be installed would overwrite an existing file, you will be prompted to overwrite it. The default answer is to keep the newer file.  If the `useModuleFolder` configuration setting is TRUE or not set, a folder containing all converted and compiled files will be installed into the same directory as the module (`.mod`) file.

Command Line Options
|Argument|Description|
|---|---|
|`--clean`|clears the cache before packing|
|`--yes`|automatically answers yes to all prompts|
|`--no`|automatically answers no to all prompts|
|`--default`|automatically accepts the default answer for all prompts|

Usage
```c
nasher install [options] [<target>...]
```

Examples
```c
nasher install                  <-- installs using first target in nasher.cfg
nasher install <target> --yes   <-- installs using <target> in nasher.cfg and answers all prompt `yes`
```

### Launch
[Converts](#convert), [compiles](#compile), [packs](#pack) and [installs](#install) all sources for <target>, installs the packed file into the NWN installation directory, then launches NWN and loads the module. This command is only valid for module targets.

Command Line Options
|Argument|Description|
|---|---|
|`--gameBin`|path to the nwnmain binary file|
|`--serverBin`|path to the nwserver binary file|
|`--clean`|clears the cache before packing|
|`--yes`|automatically answers yes to all prompts|
|`--no`|automatically answers no to all prompts|
|`--default`|automatically accepts the default answer for all prompts|

Usage
```c
nasher (serve|play|test) [options] [<target>...]
```

Examples
```
nasher serve <target>  <-- installs <target> and starts nwserver
nasher play <target>   <-- installs <target>, starts NWN and loads the module
nasher test <target>   <-- installs <target>, starts NWN, loads the module and uses the first characater
```

[Table of Contents](#hello!)

---
## Docker
---
---
Nasher can be used via docker, which will allow you run all commands without installing [nimble](#nimble), [neverwinter](#neverwinter) and [nasher](#nasher).  Typically, the `docker run` command is run from the project root folder and `$(pwd)` passed as the working directory.  However, since the project folder is passed by volume, you can specify any folder and run the command from any directory.  The following commands assume you are running the `docker run` command from the project root folder.  Additionally, these commands are windows powershell centric.  If you are using a different CLI or OS, and would like to contribute to this guide, please document your commands and forward them for inclusion.

For all Nasher Docker commands, the command portion (i.e. `docker run --rm -it -v $(pwd):/nasher nwntools/nasher:latest`) is equivalent to the `nasher` portion when using native Nasher.  So, the docker equivalent to `nasher install` is `docker run --rm -it -v $(pwd):/nasher nwntools/nasher:latest install`.

When packing, the Nasher Docker container only requires access to your root folder, so only one volumen needs to be specified.

Usage
```c
docker run --rm -it -v $(pwd):/nasher nwntools/nasher:latest [command] [options] [<target>...]
```

Examples
```
docker run --rm -it -v $(pwd):/nasher nwntools/nasher:latest pack <target> --yes
```
For commands which require access to an additional folder, you can specify a second volume to access files for the various `modules`, `hak`, `erf` and `tlk` folders in the NWN documents folder.  
*Note: techniques for referencing folders with spaces in the name and absolute paths will vary by OS and CLI.  Reference the requirements for your specific CLI/OS to get these commands to work correctly.*
```
docker run --rm -it -v $(pwd):/nasher -v //c/Users/<username>/Documents/Neverwinter Nights:/nasher/install nwntools/nasher:latest install <target> --yes
```

[Table of Contents](#hello!)

---
## Errors
---
---
`"No source files found for target"` - Caused by improper sourcing (`include = `) in either the [Sources] or [Target] section of `nasher.cfg`.  Check your [configuration file](#nasher-project-configuration).

`"This is not a nasher repository. Please run init"` - Caused by running any nasher command, except `nasher config --global` before running [`nasher init`](#unpacking) in the project folder.  Caused by incorrectly referencing the present working directory in the `docker run` command.  The reference can be CLI-specific.  For example, ubuntu/linux wants to see `$(pwd)` while PowerShell requires `${pwd}`.  Lookup the appropriate reference for your CLI.  `%cd%` only works for Windows `cmd.exe`.

`"This module does not have a valid starting area!"` - A module cannot be packed/installed without a valid starting area.  Either extract a valid starting area into the nasher project folder or manually edit (never recommended!) your `module.ifo` file at the `Mod_Entry_Area` setting.

`"this answer cannot be blank. Aborting..."` - Ummmm.  Answer it?

`"not a valid choice. Aborting..."` (cli.nim)

`"Could not create {outFile}. Is the destination writeable?"` - raised is a destination folder for file conversion does not have write permissions.  Also raised if there is an error converting the file to `.json` format.  If you permissions are set correctly, try using 64-bit versions of minGW and nim.

[Table of Contents](#hello!)

---
## Troubleshooting
---
---
[Table of Contents](#hello!)

---
## FAQ
---
---
**Can nasher `<anything you want here>`?**  Probably.

**Which configuration options have I already set?**  Configuration options are set in two locations, a global `user.cfg` and a local `user.cfg`.  To see which options, if any, are in each:
```c
nasher config --list            <-- global
nasher config --local --list    <-- local
```
**Can I use absolute or relative paths?**  Yes.

**Does nasher strip the module ID?**  Yes.

**I really need nasher to do something it doesn't, can you add this function?**  You can ask.  Nasher is actively maintained and new features are constantly added.  If your request is a feature that fits within the design criteria for nasher, it can likely be added.  [Add an issue](https://github.com/squattingmonk/nasher.nim/issues) on the [nasher github site](https://github.com/squattingmonk/nasher.nim) and it will be addressed shortly.

**I though using nasher was supposed to be easy, why is it so difficult?** You're probably doing it wrong.  Read through this document for the command you're trying to use and see if you can self-help.  As a rule of thumb, if you're doing more work after installing nasher than you did before, you're likely missing some key pieces of information and/or configuration that will make your life a lot easier.  If you can't self-help through this document, ask your question on the nasher discord, neverwinter vault discord, or [nasher github issues](https://github.com/squattingmonk/nasher.nim/issues) site.

[Table of Contents](#hello!)

---
## Help
---
If you have any questions about installing these tools, and you're sure you followed the instructions above correctly, your best bet is to get onto the [Dark Sun discord](https://discordapp.com/channels/468225176773984256/468225176773984258) and ask a question about installing the tools.  If you're not a member of our discord, you can [join](https://discord.gg/8ZxgMRc).  If you tag me (@tinygiant) in your post, I'll likely answer pretty quickly.  If you don't tag me, I may not see the question at all, but one of our many other team members might be able to help.  I'm happy to answer discord DMs also if you don't want to join the discord.

[Table of Contents](#hello!)
