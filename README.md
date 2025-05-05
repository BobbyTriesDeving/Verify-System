# BobbyTriesDeving


# MUST READ
ok so for the webhook to send you need to run a bot the source code will be in https://github.com/BobbyTriesDeving/verifybot
fill the bottoken and webhook or whatever with the CORRECT info

So, this fivem verify system was made to ensure losers stay out of your fivem server this is a STANDALONE script

/link (ingame command)

# BOBBYS WHATS THIS NEW FILE THE SCRIPT MADE?? 

the embed_sent.flag is to ensure the script doesnt send the Verify required embed 2 times

# How To Install?

put this into your sql
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(100) NOT NULL UNIQUE,
    discord_id VARCHAR(100) NOT NULL,
    fivem_id INT NOT NULL,
    ip_address VARCHAR(100) NOT NULL,
);



 
Go to the sconfig.lua

Config.BotToken = 'ReplaceWithYourToken'
Config.GuildId = 'YourGuildID'
Config.RoleId = 'YourRoleID'
Config.Webhook = the embed that sends when you start the script for the first time
Config.verifywebhook = the embed that sends when a player verifies


 
 
# Dependencies 
oxmysql
ox_lib


