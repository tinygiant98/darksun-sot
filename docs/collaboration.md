# Collaborating with Team Members

You should not be reading this document unless you're already familiar, and somewhat comfortable with, using the [building tools](tools.md) and the [workflow](workflow.md).  This document will primarily direct you to use `git` commands in order to view and utilize fellow team member's repositories so you can help them with their files.  The methods in this document should prevent you having to use other more cumbersome methods for moving documents, such as google drive or dropbox.  You will be able to directly offer edits to their files and they can merge those edits and continue their work.

* [Connecting to Another Git Repository](#connecting-to-another-git-repository)
* 

## Terminology

`fork` - a version of a clone that allows direct collaboration with a repository.  Like a clone, you will have a copy of the original repository on your machine.  Unlike a clone, however, you can easily make change to the files and suggest those changes directly to the owner of the repository from which the files are forked.

`clone` - a copy of a repository that allows one to have all repository files on a local machine.  Updates to the original repository will be reflected in the clone when requested.



## Connecting to Another Git Repository

Much like you did when you were setting up the tools in the [tool installation tutorial](tools.md) and using the [workflow](workflow.md), you will be using `git` commands to make copies of other team member's repositories.  Doing so allows you to view their working files, build a module, hak or talk with their modified files and help them troubleshoot and test issues directly on your machine.  You can then provide them suggested file changes by committing changed files directly back to their repository through a pull request.

The distinction between `forking` and repository and `cloning` a repository is very importatnt.  See the [definitions](#terminology) above.  If you don't plan on ever providing feedback to the other team member via git, cloning is appropriate.  If you'd like to directly collaborate, forking is more appropriate.

## Forking

These steps closely mirror those in the tool setup tutorial, so you should be somewhat familiar with them.  To fork a team member's repository, accomplish the following:

1. Navigate to the team member's Dark Sun repository (https://github.com/<user_name>/darksun).

2. Create a fork off of this repository by clicking on the Fork button.  Ensure you're clicking on the button, not the number next to the button. ![GitHub Fork](https://github-images.s3.amazonaws.com/help/bootcamp/Bootcamp-Fork.png)
    
    *Note:  When the forking process is complete, GitHub will automatically take you to your new forked repository homepage.  This is your repository and you can do anything you want with it without affecting the primary module repository.  You should see `<your_user_name>/darksun` near the top with `<other_user_name>/darksun` just below it.  If you're forking a repository that's also called `darksun`, GitHub may automatically append a number to it for distinction, such as `darksun1`.*

    *Note:  If you want to receive updates for changes, issues, etc., on the primary repository, you can click on the `watch` button and `star` button.*

3. Copy the web address of your newly forked repository.  The value you need for the next steps will be `https://github.com/<your_user_name>/<repository>.git`  You can copy the url from the top of your browser, click on the green clone/download button and copy the value you find there, or just write it down.  You will replace `<your_user_name>` with your GitHub username when you type it in below and replace `<repository>` with the repository name (GitHub might have changed it because your already have a `darksun` repository).

    ![Stuff](https://help.github.com/assets/images/help/repository/clone-repo-clone-url-button.png)

4. In your command line utility (powershell, git bash, vscode terminal, etc.), navigate to your `Git_Repositories` directory.  If you're using Git Bash, go into your file explorer, right click on the `Git_Repositories` folder and select `Git Bash Here` from the context menu.  This will open Git Bash and put you in the correct directory so you don't have to navigate your folder structure from the command line.

    *Note:  Each command line utility displays your current folder in a different way, but it should be obvious where you are.  Use the command `dir` to see what folders are in your current directory, `cd ..` to move backward one level in the folder structure, or `cd <folder_name>` to move to another folder.*

5. Clone the forked repository you created int step 2.  To do this, type the following into your command line:  
    ```
    git clone https://github.com/<your_user_name>/<repository>.git --recurse-submodules
    ``` 
    and press enter.  If you correctly entered the repository address, you should see some activity and reports showing copied files.  These files are being copied from your forked repository to your computer.  

6. Add an upstream to your forked repository so you can retrieve updates from the primary module repository.  Since you are not working on the primary repository, any updates to the primary repository will not automatically update to the fork you're working on.  If you want to retrieve updates from the primary repository to ensure you always have the most recent data, you need to add an upstream to your local repository.  On the command line, type the following: 
    ```
    git remote add upstream https://github.com/<other_user_name>/darksun.git
    ``` 
    and press enter.  You are using the original team member's forked repository (`<other_user_name>/darksun`) as your upstream, not your forked repository, so type the command exactly as you see above.  Adding this upstream does not automatically keep your forked repository updated with the primary repository's content.

## Questions

If you have any questions about installing these tools, and you're sure you followed the instructions above correctly, you're best bet is to get onto the [Dark Sun discord](https://discordapp.com/channels/468225176773984256/468225176773984258) and ask a question about installing the tools.  If you're not a member of our discord, you can [join](https://discord.gg/8ZxgMRc).  If you tag me (@tinygiant) in your post, I'll likely answer pretty quickly.  If you don't tag me, I may not see the question at all, but one of our many other team members might be able to help.  I'm happy to answer discord DMs also if you don't want to join the discord.

## Conclusion

I know this was a lot of information, but, again, it all boils down to just a few commands once you're used to it.  The majority of this tutorial is aimed at our audience that is new to this process.  If you've decided to use VS Code, which can accomplish a lot of these steps in a visual environment, please read the [~~VS Code Tutorial~~coming soon](vscode.md).  This is not really necessary for most content developers, but if you're a scripter, I highly recommend your consider VS Code as your primary development environment for this module.