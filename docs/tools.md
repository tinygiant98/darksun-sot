# Installing Git, Nimble, Neverwinter and Nasher

The purpose of this tutorial is to install the basic tools required to enable our workflow.  These tools will take a few minutes to install but will save countless hours of building modules and ensuring the most current files are always included.  Using all of these tools in concert will allow the team to ensure the most current files are always in the module, revert to a previous version of any files should we find faults, and build a working module in seconds.  To get these tools working on your computer, follow these steps in order.  If you're a veteran to module development and familiar with this tools, it's your option.  This tutorial is primarily aimed at those who have little experience with these tools.

## Disclaimer

There are **A LOT** of words here.  Don't let this scare you off of the idea of using these tools.  I've chosen to add a lot of detail based on the assumption you've not worked with these tools before.  If you have, you can ignore much of this.  After installing these tools and [reading the workflow tutorial](workflow.md), you should have confidence that you can easily and readily employ these tools to make quick changes to the module.  Also, this document is geared toward use by Dark Sun team members.  If you're not on the team, you can substitute your own values where appropriate.  If you're having problems, [we'll still try to help](#questions).

* [Setting up your GitHub Account](#github-account)
* [Installing Git](#git)
* [Installing Nasher and Neverwinter](#nasher-&-neverwinter)
* [Installing Nasher](#nasher)
* [Getting your Questions Answered](#questions)
* [The Next Steps](#conclusion)

## Folders and Naming Conventions

This tutorial will attempt to setup a standard method for installing and accessing your repository.  However, we cannot know exactly how the folder structure on your computer is set nor exactly where your specific installation and data folders are, especially if you've chosen a non-standard installation directory when you installed your game or any of the tools below.  If you see something like `<username>` in braces, it means you need to supply your own information and completely replace that part.  As an example, if you see `C:\Users\<usersname>\Git_Repositories\ds-sot` below and your username is `Jack`, you should end up using `C:\Users\Jack\Git_Repositories\ds-sot`.

When using Git Bash or most other command line clients, you can navigate to the folder using `cd` (change directory) commands.  `cd ..` goes backwards one folder (i.e. `C:\Users\Jack\Git_Repositories\ds-sot` --> `C:\Users\Jack\Git_Repositories`).  To go back, type `cd ds-sot` and it will take you back to `C:\Users\Jack\Git_Repositories\ds-sot`.

If at all possible, **avoid the use of spaces in any of your folder names!**  Use underscores (`Git_Repositories`) or camel case (`GitRepositories`) instead.  It makes life much easier when using the command line utility.

If "file explorer" is referenced in these tutorials, it is the tool you use to navigate files on your computer.  For windows, it's the window that pops up when you press the `(Windows Key) + E` combination.

Finally, if you see an instruction in a special block like this:

 ```
 git config --global user.name "<your name>"
 ```

 this means type it exactly as you see it, even if you don't understand why.  The only exception to this is if you need to replace a value in `<braces>`.  Everything in the command matters, the double dashes, the quotation marks, the spaces ... so no skimping.

## Read Everything

Generally, we have two types of users go through this document.  Experienced users whip through it pretty quick, skipping a lot of content with no issues.  Inexperienced users (that's most of you), also whip through it real quick, skipping a lot of content, then we end up in one-on-one conversations for 45 minutes trying to walk them through what's already here.  Read everything!  There are important notes and potential fixes for errors.  So read everything before you do it, then come back through and accomplish the steps.

If you see a note (*Note: blah blah blah*), these generally denote helpful examples or other information, but are not instructions.  Instructive steps are numbered.

## GitHub Account

In order to clone, fork and contribute to this project, you will need a GitHub account.

1. Go to the [join page](https://github.com/join) for GitHub.
2. Complete the registration process
3. Remember your username and password, you'll need this when you install and setup Git.
4. Navigate to the [Dark Sun repository](https://github.com/tinygiant98/darksun).
5. Create a fork off of this repository by clicking on the Fork button.  Ensure you're clicking on the button, not the number next to the button. ![GitHub Fork](https://github-images.s3.amazonaws.com/help/bootcamp/Bootcamp-Fork.png)
    
    *Note:  When the forking process is complete, GitHub will automatically take you to your new forked repository homepage.  This is your repository and you can do anything you want with it without affecting the primary module repository.  You should see `<your_user_name>/darksun-sot` near the top with `tinygiant98/darksun-sot` just below it.*

    *Note:  If you want to receive updates for changes, issues, etc., on the primary repository, you can click on the `watch` button and `star` button.*

6. Dark Sun maintains a second repository for custom content (hak files).  If you expect to work on custom content, repeat steps 4 and 5, but forking the [Dark Sun Resources repository](https://github.com/tinygiant98/darksun-resources) instead.  You can also use this repository to obtain and build the hak files locally on your computer.

7. Copy the web address of your newly forked repository.  The value you need for the next steps will be `https://github.com/<your_user_name>/darksun-sot.git`  You can copy the url from the top of your browser, click on the green clone/download button and copy the value you find there, or just write it down.  You will replace `<your_user_name>` with your GitHub username when you type it in below.

8. If you also forked the resources repository, repeat step 7, but use `https://github.com/<your_user_name>/darksun-resources.git`.

    ![Stuff](https://help.github.com/assets/images/help/repository/clone-repo-clone-url-button.png)

## Git

In order to efficiently contribute to the Dark Sun project, you need a git client.  Git is source control software which tracks changes to selected code and allows reversion, if necessary.  Following are the steps to obtain, install and configure your git client.  For those on Windows, you will get a tool called Git Bash which is a version of PowerShell or a command line utility.  However, any command line utility or terminal can be used to accomplish the tasks required to setup Git.

1. [Download](https://git-scm.com/downloads) and install git for your operating system.

    *Note:  If you're not interested in the command line interface, there are several [visual Git clients](https://git-scm.com/downloads/guis) that you can use.  I'm not familiar with any of them as the command line serves all necessary purposes.  If you choose to use a GUI/visual client, you're on your own for learning and employing it and it's likely we won't be able to help you resolve errors.*

2. Create a new folder on your computer's desktop `Git_Repositories`.  Avoid spaces in the title to make it easier to navigate from the command line.

3. In your command line utility (powershell, git bash, vscode terminal, etc.), navigate to your `Git_Repositories` directory.  If you're using Git Bash, go into your file explorer, right click on the `Git_Repositories` folder and select `Git Bash Here` from the context menu.  This will open Git Bash and put you in the correct directory so you don't have to navigate your folder structure from the command line.

    *Note:  Each command line utility displays your current folder in a different way, but it should be obvious where you are.  Use the command `dir` to see what folders are in your current directory, `cd ..` to move backward one level in the folder structure, or `cd <folder_name>` to move to another folder.*

4. Add your username and e-mail to the Git configuration file.  This is required if you want to submit content to the repository.  This not the user name you used to [create an account on GitHub](#github-account) in the previous section.  It's just your name.  This value and your email will be automatically attached to all commits that are pushed to the remote repository.  In your command line client, type the following:

    ```
    git config --global user.name "<your name>"
    git config --global user.email "<your.email@address.com>"
    ```

5. Clone the forked repository you created when you were making your GitHub account.  To do this, type the following into your command line:  
    ```
    git clone https://github.com/<your_user_name>/darksun-sot.git ds-sot
    ``` 
    and press enter.  If you correctly entered the repository address, you should see some activity and reports showing copied files.  These files are being copied from your forked repository to your computer.

    If you also forked the resources repository, you'll need to clone that repository.  ***WARNING: This will take a long time as there are thousands of files in this repository.***  Only do this if you forked the resources repository:
    ```
    git clone https://github.com/<your-user-name>/darksun-resources.git ds-r
    ```

6. Add an upstream to your forked repository so you can retrieve updates from the primary module repository.  Since you are not working on the primary repository, any updates to the primary repository will not automatically update to the fork you're working on.  If you want to retrieve updates from the primary repository to ensure you always have the most recent data, you need to add an upstream to your local repository.  Change directories to your `ds-sot` folder, then, on the command line, type the following: 
    ```
    git remote add upstream https://github.com/tinygiant98/darksun-sot.git
    ``` 
    and press enter.  You are using the primary repository (`tinygiant98/darksun-sot`) as your upstream, not your forked repository, so type the command exactly as you see above.  Adding this upstream does not automatically keep your forked repository updated with the primary repository's content.  I'll show you how to do that later.

    If you forked the resources repository, repeat the previous step, but with the following command:
    ```
    git remote add upstream https://github.com/tinygiant98/darksun-resources.git
    ```

Ok, that's it for Git. Let's work on the rest.

## Nasher, Neverwinter and NWNSC

Nasher, Neverwinter Tools and NWNSC are now released as executable files and no longer require native installation of nim, nimble, choosenim, etc.  Get the latest releases for each of the tools here:
[Nasher releases](https://github.com/squattingmonk/nasher/releases)
[Neverwinter releases](https://github.com/niv/neverwinter.nim/releases)
[NWNSC releases](https://github.com/nwneetools/nwnsc/releases)

After you download these tools, create a utility folder for them and put all of them together.  For example, if you have a parent folder called `GitRepositories`, but these tools in a subfolder --> `GitRepositories/utilities`. The and location don't really matter, as long as you know where they are.  Although not a requirement, you will also need to add the folder where these tools are located to your PATH environmental variable.

## Nasher and NWNSC Configuration

Nasher is a module maintenance tool written and maintained by Michael Sinclair (squattingmonk).  Using Nasher will greatly reduce your workload and shorten your workflow when deploying content to the Dark Sun module.

*Note:  most of the steps below assume you've navigated to the `ds-sot` or `ds-r` folders, which were created when you cloned your forked repository.  If you're using Git Bash, go into file explorer, find your `ds-sot` folder (`C:\Users\<username>\Desktop\Git_Repositories\ds-sot`), right click on the `ds-sot` folder and select `Git Bash Here` from the context menu.  If on the command line, us `cd` to move to the appropriate folder.*

1. After installation, you can verify access to these tools by type the following:
    ```
    nasher -v
    ```
This will display the current nasher version.  If it fails, you need to add the folder where these tools are located to the PATH environmental variable.  There is also a possbility that your CLI may need to be restarted.  Some CLIs do not re-read the PATH variable while they are open.


2. Configure NWNSC.  NWNSC is an external script compiler for Neverwinter Nights created by glorwinger (sorry, I don't know his real name).  He created this tool so that module developers like yourselves could compile scripts without having to use the toolset.  NWNSC provides much better feedback and can be used with almost any development environment (including [VScode](vscode.md)) to test script compilation without opening the toolset.  The following command uses the path where your NWNEE game files are installed, not the path to the user content that is normally in your documents directory.  To configure your installation path, type ***one*** of the two following commands into your command line utility (read both before, then choose your own adventure):

    If your folder names do not have spaces in them (good job!):
    ```
    nasher config --nssFlags:"-n C:/<path>/<to>/<NWNEE> -owkey"
    ```
    *Note:  A common error is to have a trailing '/' after the path in the command above.  There should be no trailing '/'.  Additionally, the slashes need to be forward, not back.

    If your folder names have spaces in them (boooooooooooo!):
    ```
    nasher config --nssFlags:"-n \"C:/<path>/<to>/Neverwinter Nights\" -owkey"
    ```

    Finally, even when nwnsc.exe -- or binary-- is included in the base directory, some situations may require an explicit reference to its location.  The first time you try to build the module in the [workflow](workflow.md), if you receive an error stating that `\nwnsc.exe\ cannot be found`, you must run the following command.  **Replace the folder names with your folder structure to your local git repository.**  The double backslashes are important.
    ```
    nasher config --nssCompiler:"C:\\Users\\<username>\\Desktop\\Git_Repositories\\utilities\\nwnsc.exe"
    ```

## Questions

If you have any questions about installing these tools, and you're sure you followed the instructions above correctly, you're best bet is to get onto the [Dark Sun discord](https://discord.com/channels/744704910842527815/744704911270477918) and ask a question about installing the tools.  If you're not a member of our discord, you can [join](https://discord.gg/VVvrb4CkeG).

## Conclusion

Git and Nasher will be the primary programs we will use when we conduct our repository workflow.  Once all of this is setup, it only takes a few seconds to create a working module from the repository.  Any changes you make can be reflected within a working module within a few more seconds.  How to do all of this will be handled in the [workflow tutorial](workflow.md).  Read that next.
