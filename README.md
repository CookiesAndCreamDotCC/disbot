DisBot 🤖
======

[![Discord](https://img.shields.io/discord/1347049108665532519?style=plastic&label=Discord)](https://discord.cookiesandcream.cc/)

This repository contains the source code for the bots that reside in the [Cookies & Cream Discord server](https://discord.cookiesandcream.cc/).

### Requirements
Below are the requirements if you want to run your own instance of the bot.
* a [Discord](https://discord.com/) account
* a [Ruby](https://www.ruby-lang.org/) interpreter
* [discordrb](https://github.com/shardlab/discordrb)
* [sqlite3](https://github.com/sparklemotion/sqlite3-ruby)

### Installation
1. You can use the Gemfile with Bundler to install the necessary gems by running:
    * `bundle install`

    If you prefer to install the gems manually, you can run:
    * `gem install discordrb sqlite3`

    If you want to install the gems locally rather than at the system-wide location or if you lack Administrator/root privileges:
    * `gem install discordrb sqlite3 --user-install`

2. Log into the [Discord Developer Portal](https://discord.com/developers/home).

3. Click "Applications" on the navigation menu to the left.

4. Click the "New Application" button, give your application a name, and accept the terms.

5. Under the "Overview" section for your application, click "Installation".

6. Set the "Install Link" to "None".

7. Click "Bot" in the "Overview" section.

8. Generate a token for the bot and make note of it. This is used to authenticate your bot.

9. Scroll down to the "Privileged Gateway Intents" section and enable "Server Members Intent" and "Message Content Intent".

10. Click "OAuth2" in the "Overview" section.

11. Scroll down to the "OAuth2 URL Generator" and check "Bot".

12. Scroll down further and check the permissions you want the bot to have. "View Channels" and "Send Messages" are the essential permissions.

13. To invite the bot to a server, copy the "Generated URL" link and open it.

### Running the Bot
1. Configure `disbot.yml` to your liking. Be sure to add the bot token that was generated earlier from the developer portal, the server ID, and the ID of the user who is the bot administrator.

2. Run the bot: `ruby disbot.rb`

3. If you want the bot to start automatically when your system boots, you can consider creating an init script or a systemd unit file.

### Support
To report bugs or request features, you can [submit an issue](https://github.com/CookiesAndCreamDotCC/disbot/issues).

You can also [join the Cookies & Cream Discord server](https://discord.cookiesandcream.cc/) if you need assistance. Please use the #development channel.
