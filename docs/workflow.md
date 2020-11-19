# Creating an Efficent Workflow

You should not be reading this document unless you've already completed the [tool installation tutorial](tools.md) or you are an experienced developer and you are already famliar with these tools.  If you haven't installed the basic development tools we're using, [do it, do it now!](tools.md)

The purpose of this tutorial is to create an efficient and repeatable workflow pattern that will allow all contributors, no matter their skill and knowledge level, to substantially contribute to this project without unnecessarily burdening other team members.  This tutorial will provide basic directions on how to use the tools you installed in the last tutorial and a methodology for how tools should be employed together.

## Disclaimer

There are **A LOT** of words here.  Don't let this scare you off of the workflow idea.  I've chosen to add a lot of detail based on the assumption you've not worked with these tools before.  If you have, you can ignore much of this.  But to build your confidence that this is actually a simple process, everything below boils down to a few steps:

```
git pull upstream master
nasher install ds --yes
```

Accomplish and save all of your amazing work.

```
nasher unpack ds
git add .
git commit -a -m '<your message here>'
git push origin master
```

That's it! Once those steps are accomplished, you've updated all your work, made your changes and re-published all your work to your remote repository.  Okay!  Let's get started...

* [Git Terminology](#git-terminology)
* [Nasher Terminology](#nasher-terminology)
* [The Workflow](#workflow)

## Git Terminology

These definitions are provided to help you understand what some of the Git terminology means.  We will not be using all of these terms in this tutorial, but you will likely hear about some of them as you work with Git.  Some of these commands and term reference advanced usage, so don't worry if you're not familiar with them.  Reading these definition is not strictly necessary, but if you see a Git term in this tutorial that you're not familiary with, it's probably in this list.

`Clone` - a copy of a repository or the act of copying a repository.

`Local Repository` - the files that are on your computer.  Changes to these files will not be pushed to your remote repository, and therefore cannot be part of a pull request, until you save, stage, commit and push the changed files.

`Remote Repository` - the files that are on the GitHub servers.  Changes to these files will only occur when you request an upstream pull or when you push committed changes.

`Upstream` - the controlling repository for your fork.  This is the repository you forked off of.  In our case, it's the primary repository located at https://github.com/tinygiant98/darksun.

`Working Tree` - another name for the files in your local repository.  Typically, working tree is referenced as being clean (no changed files) or dirty (files have been changed, but not committed and pushed).

`Pull` - request to copy all changed files from the remote repository to the local repository and merge those changes with your local files.

`Push` - request to copy all commited files from the local repository to the remote repository.

`Fetch` - request the metadata for all changed files from the remote repository, but not to copy or merge the changed files from the remote repository.  This allows you to see potential conflicts with changed files in the remote repository vs. changed files on your local repository.

`Merge` - combining files from one fork with the files of another.  The most common type of merge you will see with this project is merging your changes with the primary repository.

`Stage` - telling your repository which changed files will be committed to the repository on the next push command.

`Commit` - committing changed files to the remote repository.  This requires a comment to be added as to why you're are committing these files.  The comment limit is 50 characters and can be anything you want (i.e. updating half-giant model).

`Pull Request` - a request sent from your remote repository to the primary repository when you think your files are ready for primetime.  This will signal the primary repository keepers to review your work and merge it with the primary repository.

`Stash` - "pauses" your changes so you can save your work and clean your working tree without having to stage and commit your changes to your remote repository.  This is a workaround to allow you to perform updates that require clean working trees (such as upstream updates) without having to commit all of your changes first.

`Branch` - a version of your repository that diverges from the main working project, but is still a part of your repository.  You can create a branch if you want to test how a change will work on the repository without changing the original files.

## Nasher Terminology

These definitions tell you what each of the major Nasher commands do.  Reading these definitions is not strictly necessary, but if you're confused by what Nasher is doing when you type a command, this is probably a good first place to look.

`unpack` - converts all module resource files to .json files so they can be tracked by Git and shared with the rest of the team.  Script files (.nss) are plain text files, so they are not converted to .json.

`convert` - converts all .json sources in your local repository to the native gff format for use within the module.  The command will turn the unpacked .json files back into the correct file format, such as .uti.

`compile` - compiles all of the scripts in your local repository without building a module.  This allows you to batch compile all of the scripts to check for errors.

`pack` - coverts and compiles all of the resources in your local directory into a module file (.mod) and places that file into the base folder of your local repository.

`install` - converts, compiles and packs all of the resources in your local repository into a module file (.mod) and copies that file into the base folder of your local repository as well as into the modules folder of your NWN:EE installation.  If you're creating a hak, erf or tlk file, this command will copy the file into the correct directory.

# Workflow

Here is the general workflow I've developed and it seems to be relatively efficient in adding new content.  Any references to "local" or "remote" repositories in this document are specifically referencing your forked repository (`https://github.com/<your-user-name>/darksun`).  Any reference to the "primary" repository is referencing the primary Dark Sun repository (`https://github.com/tinygiant98/darksun`).

* [Working with Branches](#branches)
* [Updating Your Forked Repository](#updating-your-forked-repository)
* [Building the Module](#building-the-module)
* [Adding Content](#adding-content)
* [Unpacking the Module](#unpacking-the-module)
* [Cleaning up Your Workspace](#cleaning-up-your-workspace)
* [Staging and Committing Changes](#staging-and-committing-changes)
* [Updating the Remote Repository](#updating-the-remote-repository)
* [Request Review of New Content](#request-review-of-new-content)
* [Getting your Questions Answered](#questions)
* [The Next Step](#conclusion)

All calls to installed tools will be via the command line interface.  Graphical user interfaces will not be discussed here.  If you use a GUI, you are responsible for learning and using your installed system.  The installed tools I'll reference in this tutorial are `git` and `nasher`.  All commands should work readily in your command line utility so long as you have navigated to your primary Dark Sun forked repository folder.  If you followed the example in the tools installation tutorial, that repository will be located at `C:\Users\<username>\Desktop\Git_Repositories\ds`.  If you chose to locate your repository somewhere else, ensure you are in your chosen location before running any of the commands below.

## Branches

The concept of branching is extremely important to using git successfully.  If you think of your repository as a tree, you always have one main branch, the trunk.  The trunk of your repository is the master branch.  When you see a command below like `git pull upstream master`, "master" is the name of the branch we're using.  It just so happens that master is the default name given to the main repository.  When you do your development work on this module, you will want to work on a different branch.  Creating a new branch protects your primary branch, the trunk ("master").  **Branches contain all the files from the trunk**, but allow you to change files and test new additions or deletions without affecting the trunk.  Much like a tree, you can grow or lop off a branch without the entire tree dying.  In our case, we want to create a branch for each section of a new project.  Let's say you're a 3D model contributor.  All of the files in our various hak paks are part of our master branch, the trunk of the tree.  You want to create an entirely new tileset.  If you do this on the master branch, it will be very difficult to revert to the original files in case you mess something up, especially after a commit (the concept of commits are [defined above](#git-terminology) and [discussed below](#committing).  Just as with a real tree, you don't want to start messing with the trunk (the "master" branch), or your tree could end up dead.  So, you do your development on a different branch, and once you're happy with everything you've done, and you've tested it, you can either merge that branch with your trunk (the master branch), delete the entire thing if you don't like it, or merge just the files and changes you are happy with.  You can even [send a pull request](#request-review-of-new-content) to the primary repository directly from that branch.

Here's how we create branches:

1. Create the branch.  To create a new branch in your local repository, use the following command:
    ```
    git branch <branchname>
    ```

Replace <branchname> with whatever name you want to use.  Spaces are not allowed in branch name and git will automatically replace them with dashes (`-`).

*Note:  Creating a branch only creates it on your computer.  No one else knows about it, not ever your remote repository on GitHub.  You will [publish your branch](#updating-thre-remote-repository) to your remote repository further down in this tutorial.*

2. Switch you repository over to the new branch.  You can choose which branch you want to work on at any time.  So if you created 20 branches for 20 different projects, you need to tell git which one you are currently working on.  Do this by using this command:
    ```
    git checkout <branchname>
    ```

    This tells git that you want to work on that branch.  Remember, master is your tree trunk, but it's also just a branch, so if you want to work on your master files (not recommended), you can just type in `git checkout master` and now you're back on your trunk.

3. Confirm you've made the switch.  After you switch branches, you want to confirm which branch you're on.  Use the following command:
    ```
    git status
    ```

    This first line to appear will be which branch your on and it will say `On branch <branchname>`.  If you have several modification projects going at the same time, you will constantly be using the `git checkout` commands to swap between project.

4. Follow the rest of the workflow.

*Note:  If you forget what you names your branch, you can use the command `git branch -a` and all of your branches will be listed.*

*Note:  When you [build the module](#building-the-module) below, the module will be built with whatever files are on the branch that you've checked out.  So, if you `git checkout master`, the module you build will be a carbon copy of the primary module (because you keep your repository up to date).  If you want to test out the changes you've made, use `git checkout <branchname>`, then rebuild the module and your new changes will be there.  With this conecpt, the module file itself is never sacred and you will overwrite it constantly as development continues.  This works the same for non-toolset files.*

*Note:  Changing branches can be confusing at times because it may appear your files change for no reason.  If you're working on a branch and can't find your files, use `git status` to to see if you're on the right branch.  When you `git checkout master` your original files will "appear" in your repository folder.  When you `git checkout <branchname>`, your modified files (the files from that branch), will "appear" and will seem to overwrite your original files in the same location.  Rest assured your other files are still safe and secure, just switch back to the other branch to get them.*

## Updating Your Forked Repository

Your forked repository will not automatically update from the primary repository until you ask it to.  Updating your fork will ensure you always have the latest version of any files others are working on that have already been accepted into the primary repository.  You will not be able to view other developer's work unless you navigate to their GitHub forked repository.

*Note:  This step is not strictly necessary.  If you're not working on any of the base module files that are sourced from the primary repository and your work does not depend on those files being current (such as adding new models, etc.), then you can [skip this step](#building-the-module).  Again, **this step does not have to be accomplished on a daily basis.**  One of the reasons we use branches to do our work is because updating the primary repository can mess with your pull requests if you update it while a pull request is in the process of being approved.  If you do your work on a branch, updating your local repository will not affect any pull requests you have out for that branch.

To update your forked repository, navigate to your `Git_Repositories\ds` folder and run the following command in your command line utility:
```
git checkout master
git pull upstream master
```

git -> the program we're using
pull -> the action we're taking (see [Git Terminology](#git-terminology))
upstream -> where we're getting the files from
master -> the name of the branch we're getting the files from

This command will force your local (on your machine) repository to update all files that are sourced from the primary repository.  If you've added new files in your fork, those files will be ignored.  If there are no new or changed files in the primary repository, no files will be updated in your local or remote repository.  `git pull upstream master` does not update your remote repository, but your remote will be updated the next time you `git push origin master` when your workflow is complete.

*Note: A common mistake that causes this command to fail is a dirty working tree.  If you have any changed files in your local repository that were sourced from the primary repository that you have not yet committed to your remote repository, and the files on the primary repository have changed, git will not allow the changes to be incorporated because it does not want to delete your work without your permission.  To resolve this issue, you must commit, undo or stash all of your changes ("clean your working tree") before updating your repositories with an upstream request.*

## Building the Module

*Note:  If you are modifying non-toolset files (such as scripts, models, 2DAs, etc.), you do not need to build the module to do your work.  Open your work directly from the repository directory on your computer, do your work in whatever program you use, and re-save the work into the repository.  Then skip down to the [staging and committing section](#staging-and-committing-changes) below to continue your workflow.  So, if you are not building items, areas or other toolset-centric resources, you can work completely outside the toolset and save yourself a few steps.*

Now we're ready to build a module file so we can start working on it.  In your command line utility, type the following:
```
nasher install ds --yes
```

This command will convert, compile, pack and install a module file into your modules folder.  This will make it available immediately to the toolset when you open it.  If you're given the option to open the module via a folder tree, take that option.  If you've [updated your repository](#updating-your-forked-repository), this module file will be the most current module we're using.

*Note:  The module will be built with the files from your current branch, so if you don't see your changes, you might have the wrong branch checked out.*

#### Errors
It is possible that you could receive some script compilation errors during the build process.  If you're not working on scripts, this shouldn't be happening, so please contact @tinygiant on the Dark Sun discord with the error information (screenshot of the output is preferred) and we'll get it fixed.  If you are working on scripts, fix your errors and re-attempt.  If you are getting compilation errors you don't understand or can't otherwise resolve, please see the [questions](#questions) for contact information.  Script compilation errors will not keep you from working on non-script resources, so if you don't get an answer, continue your workflow and we'll get it fixed as soon as we can.

## Adding Content

#### Toolset

After installing the module and attempting to open the module in the toolset, you will be given the option to open the `.mod` file or open the folder directory as a module.  In order for the unpack process to work correctly, **you must opt to open the folder directory as a module**.  Beyond that, I can't give you a lot of direction here.  If you're adding content via the toolset, then do your thing and save your work when you're done.  

#### Other Files

If you're reading this, then you didn't read my note about not needing to build the module for non-toolset file modifications.  If you're working in any utility except the toolset, just open the files you need directly from the repository (after you've checked out the branch you want to work on) and save them to the same place when you're done.

#### Tracking New Files

Any new files you add, either in the toolset or via copy/paste, will not automatically be tracked by Git for pushing to the repository.  In order to track all of your new files, type the following into your command line utility:
```
git checkout <branchname>
git add .
```

The `.` tells Git to ensure all files in your repository, including subfolders, are included in your repository.  This will also stage all new and modified files for the next commit.  If you only want to stage a specific file, you can use `git add <filename.ext>`.

## Unpacking the Module

If you've added content to the module and saved your work, you can unpack that work back into your repository.  **You do not need to *build* the module within the toolset to do this.**  Building the module compiles the scripts, but we can use nasher (via nwnsc.exe) to do that much more reliably and with better feedback.  To unpack the module, accomplish the following:

1. Ensure all of your toolset work is saved.
2. Unpack the module into your repository with the following:

    ```
    nasher unpack ds
    ```

This is the most conservative way to unpack the module as it will prompt you for a yes or no answer for any major changes, such as deleting files from the repository that you've removed in the toolset.  It will not overwrite any files that have not been changed nor any files that don't exist in the module (such as these markdown files).  There are other command arguments you can use to make the unpacking process go faster.  You may wish to use these when you're more comfortable with the process.

`nasher unpack ds --removeDeleted:true --yes`, will unpack the module, remove any deleted files without prompt and, if there are any prompts, it will force answer them with yes.  This is a command you may want to use if all you've done in the toolset is remove some resources, such as items, areas, etc.  Otherwise, the files will still exist in the repository and will be built into the next install.

`nasher unpack ds --removeDeleted:false --no` will unpack the module, keep all the files in your repository, even if you deleted them in the toolset and force answer no to any prompts that might come up.  If you delete files in the toolset (such as removing items or areas), I recommend removing the deleted files from your repository with the `--removeDeleted:true` argument.  Otherwise, the files will be included in your module when you build it again the next time you work on it.

*Note:  If you're just finishing for the day and coming back to it tomorrow, you don't need to accomplish the following steps.  If you've finished a major revision and want to publish it, continue on.*

## Cleaning up Your Workspace

Now that you've done your work and unpacked it back to your repository, you can clean up your workspace.  This step is never strictly necessary, but it does clean up some files to ensure you're not accidentally using old files in your work.  Also, it reduces some of the prompting you will see when using nasher commands.

1. Delete the module file and the module working directory in your modules folder.
2. Delete the module file, if you haven't already, in your local repository folder.

## Staging and Committing Changes

If you've decided to use VS Code as part of your development environment, see the [~~VS Code tutorial~~ coming soon](#vscode.md) to get detailed information on staging, committing and pushing changes to your repository.

You do not have to stage and commit changes every time you do your work.  However, if others are depending on the work you're doing, you'll want to publish your changes as soon as they're complete.  If you're planning on [submitting a pull request](#request-review-of-new-content), you must commit your changes first.

#### Staging

You stage your work by adding it to the next commit.  Previously, you used the `git add .` command to add new files and noted that doing this also staged them for the next commit.  If you've modified files in the toolset (or some other way) and they're now in your repository, you can check the status of those files by using the following command:
```
git status
```

This will display all new and changed files in your repository and whether those files will be included in the next commit or now.  If you see any files that are marked as not being committed, but you want them include, run the `git add .` command again to ensure they're included.  If you don't want to include all of the changed file, but just some specific file, you can use:
```
git add <filename.ext>
```

This will stage only the selected file to the next commit.  Use `git  status` again to check the status of these files.

*Note:  Once you're comfortable will this process, and if you want to include all changed and new files to the next commit, you can completely skip the staging step.  See the [committing](#committing) section below on how to do that.

#### Committing

Once all the files you want sent to your remote repository are staged, you have to commit them and add a commit message.  Ensure you are on the correct branch (i.e. `git checkout <branchname>`). The `<your message here>` section below is a quick note (less than 50 characters) you can inlude so people know what the commit is for.  Use the following command:
```
git commit -m "<your message here>"
```

If you want to skip the staging step and include all new and changed files in the next commit, you can use the following:
```
git commit -a -m "<your message here>"
```

The `-a` tells Git to stage all tracked files.  Much like every other step, ensure you're on the branch you want to be on before staging and committing files.

#### Pushing

We're almost there.  Everything is updated on your local computer, but not sent to your remote repository yet.  To push all of your committed changes to your remote, type the following into your command line utility:
```
git push origin <branchname>
```

If you're working in your master branch (stop it! you know you shouldn't be working on your master branch!), the previous command would be `git push origin master`.  If you haven't already published your branch to your remote repository, this will do so and send all of your changed files with it.

Well, we're finally here.  All of your hard work has paid off and it's now in your remote repository for the world to see.  You can leave it there, delete it, change it, or do whatever you want with it.  If you want to have it incorporated into the base module, however, you need to [submit a pull request](#request-review-of-new-content).

## Request Review of New Content

This is also known as a pull request.  To submit a pull request, go to your forked repository's home page on git hub (`https://github.com/<your-user-name>/darksun`).  Near the top, underneath the summary section that shows all of the commit and branch numbers, but above the files, you should see a couple of buttons that look like this: 

![pull request button](https://help.github.com/assets/images/help/pull_requests/pull-request-start-review-button.png)

Click on the `New Pull Request` button.  The next screen will show you all of the changes you've made, including file additions.  These changes will be based on your selections at the top.  At first you will probably see this:

![base pull request](images/PRMaster.jpg)

But you're working on a fork, so you don't want to compare the master branches because they're the same anyway.  To select the branch you're working on, click on `compare across forks`.  Once you do that, you will see the options change to something like this:

![fork pull request](images/PRdevelopment.jpg)

1. In the `base repository` drop-down, select `tinygiant98/darksun`.
2. In the `base` drop-down, select `master`.
3. In the `head repository` drop-down, select `<your_user_name>/darksun`.
4. In the `compare` drop-down, select the branch you want to pull from `<branch_name>`.  This will likely be `master` unless you've created another branch.

Give your pull request a title and add some commentary on what you did and why you did it.  The team member that ends up reviewing the pull request should not have to contact you about what you've done because, hopefully, it's all well explained in this commentary section.  Finally, submit your request!

 ![pull request submission button](https://help.github.com/assets/images/help/pull_requests/pullrequest-send.png)

 Finally, just because you send a pull request doesn't mean your work will be accepted on the first attempt.  It will be reviewed and, if some work has to be re-accomplished, the reviewer will add a comment or review to your pull request detailing what changes need to be made to make your pull request acceptable for merging.  Go to your repository page on GitHub (`https://github.com/<your_user_name>/darksun`).  At the top, you'll see several tabs, one of them is `Pull Requests`.

 ![pull request tab](images/PRCount.jpg)

 Click on the `Pull requests` tab and your PRs will be listed.  Click on the PR you're interested in and all of the commends associated with the pull request will be shown.

 When you accomplish whatever re-work needs to be done on your branch, and you commit the changed files again, the changed files will automatically be added to your pull request.  **You do not need to submit a new pull request.**.  Just go back to the `Pull requests` tab on your GitHub page and you should see the new commit there.  The person that requested changes will have a notification sent that you added a new set of committed files so they can review your work again.

## Questions

If you have any questions about installing these tools, and you're sure you followed the instructions above correctly, you're best bet is to get onto the [Dark Sun discord](https://discordapp.com/channels/468225176773984256/468225176773984258) and ask a question about installing the tools.  If you're not a member of our discord, you can [join](https://discord.gg/8ZxgMRc).  If you tag me (@tinygiant) in your post, I'll likely answer pretty quickly.  If you don't tag me, I may not see the question at all, but one of our many other team members might be able to help.  I'm happy to answer discord DMs also if you don't want to join the discord.

## Conclusion

I know this was a lot of information, but, again, it all boils down to just a few commands once you're used to it.  The majority of this tutorial is aimed at our audience that is new to this process.  If you've decided to use VS Code, which can accomplish a lot of these steps in a visual environment, please read the [~~VS Code Tutorial~~coming soon](vscode.md).  This is not really necessary for most content developers, but if you're a scripter, I highly recommend your consider VS Code as your primary development environment for this module.