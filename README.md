# Unreal Engine iOS Build Shell Scripts
A collection of shell scripts mainly used in a Jenkins freestyle project to get files from source control (git/p4), build, cook, stage, package iOS app, upload to app center, and archive/compress app, along with notifying users about build stage process through slack. Inspired from [skymapgames/jenkins-ue4.](https://github.com/skymapgames/jenkins-ue4)

Each shell script **needs to be modified** to match your workspace/paths/directories, so please fork the repo and make the changes accordingly. Also, each shell script will need permission to run, to do so, run `sudo chmod 755 PATH_TO_FILE_HERE`, for each shell script.

At the time of writing, April 2022, Unreal Engine 5 has trouble compiling with XCode 13.3, and 13.3.1 for iOS, so I recommend sticking with version 13.2.1. 

## Step 0 | Slack (Optional)
You'll need your own Slack workspace and Slack app to make an incoming webhook url.
Creating a Slack app to post messages through the terminal may seem like a daunting task, however, [this 2 minute video](https://www.youtube.com/watch?v=6NJuntZSJVA) shows that its actually kind of simple!

After editing the `slack_webhook_url` variable in [slack.sh](https://github.com/MongoWobbler/UE_iOS_Builder/blob/master/slack.sh) you can post slack messages in terminal with the shell script! Example below:

```
/UE_iOS_Builder/slack.sh "Hello World!"
```

## Step 1 | Source Control (Semi-Optional)
This step is semi-optional because of how your source control is configured. You may be using only Git, or only Perforce, or both! Maybe some other form of source control? Hopefully you're using some form of source control.

So, depending on your source control configuration, you may have several steps of [git_pull.sh](https://github.com/MongoWobbler/UE_iOS_Builder/blob/master/git_pull.sh) and/or [p4_sync.sh](https://github.com/MongoWobbler/UE_iOS_Builder/blob/master/p4_sync.sh). For example, you may need to pull engine source from github **and** pull game source as well. However, your game content could be stored in perforce, so then you would use you [p4_sync.sh](https://github.com/MongoWobbler/UE_iOS_Builder/blob/master/p4_sync.sh) in that case.

### Perforce
Unfortunately, in MacOS, Jenkins does not get `/usr/local/bin` as part of the path, so we must add it ourselves manually **if** that is where the p4 file lives. That is what the first line is about in the [p4_sync.sh](https://github.com/MongoWobbler/UE_iOS_Builder/blob/master/p4_sync.sh), `path_to_p4="/usr/local/bin/"`. 
The other variables that will need editing are a bit more straight forward, such as `server_port`, which is the ip address and port to the perforce server to sync from. 

To avoid having to type in the login credentials every time you sync, you'll need to make sure user that Jenkins will use is in a p4 group set that has "Duration before password expires" set to "Unlimited". You can find p4 groups by opening up p4admin. You may need a p4 administrator to add/create correct the group and user. After adding the p4 user to a group with a password that does not expire, you'll still need to login at least once to get the p4 ticket.

### Git
Git is slightly more involved for the initial setup, mostly because you'll need to create a ssh key. [This article by Haydar](https://haydar-ai.medium.com/learning-how-to-git-using-ssh-instead-of-https-91f09cff72de) does a great job going over process, but I'll write my notes below as well.

**NOTE:** You only need **ONE** key per computer, since this works on your github profile across **all** of your repos!
1. Open terminal and run the following
```
ssh-keygen
```
the `ssh-keygen` command will ask you for a filename, so enter the **full path**, something like:
```
/Users/USERNAME/.ssh/id_rsa_github
```
After that, it'll ask you for a passphrase, you can leave the passphrase empty
2. Open the generated public key, the one ending with `.pub`, copy that first line
3. Add the key to **your github profile**, by going to your user settings (top right), then press on SSH and GPG keys on the left, and add **New SSH Key**.
4. For **EVERY** repo that you'll need to use, you need to replace the remote url to use ssh, byt getting the ssh key link from github (go to clone button in github repo, and choose ssh, copy that link). Then run the following command in the directory.
```
git remote set-url origin git@github.com:USERNAME/UnrealEngine.git
```
5. You can check the link of the remote by typing `git remote -v` 
6. One thing the article above fails to mention is to add the key to the ssh agent. To do so [follow the instructions here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent), mostly the part about creating starting a ssh-agent by running the command `ssh-agent -s`, then making a config file in `/Users/USERNAME/.ssh/config`, and adding the following text to it:
```
Host *
  AddKeysToAgent yes
  IdentityFile /Users/USERNAME/.ssh/id_rsa_github
```

Finally, edit the variable `your_git_repo` in [git_pull.sh](https://github.com/MongoWobbler/UE_iOS_Builder/blob/master/git_pull.sh) to the path to your git repository.

## Step 2 | Building
This step will build the engine and the game, cook the content, stage the content, and package it all into an .ipa file. You'll need to make sure you have a valid iOS Distribution certificate, a unique identifier, iPhone devices, and an Ad hoc profile set up through the [Apple Developer site](developer.apple.com). Assign the identifier, proper certificate, and profile in the iOS packaging options of the project settings for your game. [Vice Versa Studios' video](https://youtu.be/M4zPvbennYA) does a pretty good job at walking through the profiling process.

The building configuration is set to shipping since I **think** that is the only way to distribute apps to other devices through AppCenter. The configuration is also set to `clean`, which means the Unreal Build Tool will delete all intermediate files before building every time, which means it'll have to build everything from scratch all over again. Cleaning is the preferred way of working with continuous integration since it lets you catch anything that might have gone wrong.

Make sure to edit the following variables in [build.sh](https://github.com/MongoWobbler/UE_iOS_Builder/blob/master/build.sh) to match your configuration.
- `project_path` = Full path to the your game's .uproject file.
- `archive_dir` = A directory to put the finished .ipa in, could be anywhere in your computer.
- `uat` = Full path to the Unreal Automation Tool shell script. This would be in your engine source.

## Step 3 | Uploading to AppCenter
You'll need to install the [AppCenter command line interface](https://github.com/microsoft/appcenter-cli) (CLI) in order for [upload.sh](https://github.com/MongoWobbler/UE_iOS_Builder/blob/master/upload.sh) to work. To do so, first install [node.js](https://nodejs.org/en/). Node.js and npm usually get installed in `/usr/local/bin` which is fine as long as `/usr/local/bin` is in your $PATH.

Next, install appcenter command line interface by typing the following into the terminal
```
npm install -g appcenter-cli
```

Once AppCenter CLI has been installed, you'll need a token in order to not have to type in credentials every time you try to upload an app. To get a token, follow the following steps:
1. Go to [appcenter](https://appcenter.ms/), and make a new app if you have not done so already. 
2. In your user settings (top right), go to account settings, then press User API tokens, New API token.
3. Type in a description for your token, and grant it full access so you can have better access to all of the command line interface. Keep this token safe and secret and do not share it with anyone!
4. Copy the given token and paste it in the `appcenter_token` variable in [upload.sh](https://github.com/MongoWobbler/UE_iOS_Builder/blob/master/upload.sh).

Make sure to edit the remaining variables in [upload.sh](https://github.com/MongoWobbler/UE_iOS_Builder/blob/master/upload.sh)  to match your workspace/configuration.
- `directory` = The directory where the .ipa was placed after building. This is the same directory as `archive_dir` specified in the build step + `/IOS` since Unreal Engine adds the IOS directory.
- `path_to_appcenter` = Where the appcenter CLI was installed, usually `/usr/local/bin`, you can double check by typing `which appcenter` into the terminal.
- `appcenter_token` = The token you get from [appcenter](https://appcenter.ms/). See steps above.
- `appcenter_group_name` = The name of the group that will be notified once upload is finished.
- `appcenter_app_name` = The full name of the app that was made in [appcenter](https://appcenter.ms/) including username and app. You can use the `appcenter app list` command to see all available app names.

## Step 4 | Archiving
This step differentiates the .ipa that was created by appending the date and time it was created to the file name and zips up the .ipa to save some storage space. The only variable needed to change in [archive.sh](https://github.com/MongoWobbler/UE_iOS_Builder/blob/master/archive.sh) is the `directory` variable that should be the same as the one in Step 3. 
- `directory` = The directory where the .ipa was placed after building. This is the same directory as `archive_dir` specified in the build step + `/IOS` since Unreal Engine adds the IOS directory.

## All Together Now!
In Jenkins, I have a freestyle project that with each shell script as a build step, so it ends up looking something like this:

Build Step 1
```
/UE_iOS_Builder/slack.sh "Pulling Unreal Engine Source from GitHub"
/UE_iOS_Builder/git_pull.sh
```

Build Step 2
```
/UE_iOS_Builder/slack.sh "Getting latest Content from Perforce"
/UE_iOS_Builder/p4_sync.sh
```

Build Step 3
```
/UE_iOS_Builder/slack.sh "Building App"
/UE_iOS_Builder/build.sh
```

Build Step 4
```
/UE_iOS_Builder/slack.sh "Uploading to AppCenter"
/UE_iOS_Builder/upload.sh
```

Build Step 5
```
/UE_iOS_Builder/slack.sh "Archiving app"
/UE_iOS_Builder/archive.sh
```
## Other Useful Resources
- [How to wake MacOS from windows](https://www.tweaking4all.com/forum/macos-x-software/waking-up-a-mac-with-wake-on-lan/#post-2867) since waking on LAN magic packet stuff does **not** appear to work on MacOS.
- [How to trigger a Jenkins remote build](https://www.youtube.com/watch?v=ZuAdOsPfQfk). Note that user and password are separated by a colon `:`, and password and IP address are separated by the at address sign `@`.
