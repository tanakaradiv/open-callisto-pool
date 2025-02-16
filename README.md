## Open Source Callisto (CLO) Mining Pool

![Main page of open-callisto-pool](https://raw.githubusercontent.com/ethpool-update-project/open-callisto-pool/master/misc/pool.PNG)

[![Build Status](https://api.travis-ci.org/ethpool-update-project/open-callisto-pool.svg?branch=master)](https://travis-ci.org/ethpool-update-project/open-callisto-pool)
[![Report Card](https://goreportcard.com/badge/github.com/ethpool-update-project/open-callisto-pool)](https://goreportcard.com/report/github.com/ethpool-update-project/open-callisto-pool)

### Features  

**This pool is being further developed to provide an easy to use pool for Callisto miners. Testing and bug submissions are welcome!**

* Support for HTTP and Stratum mining
* Detailed block stats with luck percentage and full reward
* Failover geth instances: geth high availability built in
* Modern beautiful Ember.js frontend
* Separate stats for workers: can highlight timed-out workers so miners can perform maintenance of rigs
* JSON-API for stats
* PPLNS block reward
* Multi-tx payout at once
* Beautiful front-end highcharts embedded
* Patched for eth london fork support

#### Proxies

* [Ether-Proxy](https://github.com/sammy007/ether-proxy) HTTP proxy with web interface
* [Stratum Proxy](https://github.com/Atrides/eth-proxy) for Ethereum

## Guide to make your very own Callisto mining pool

### Building on Linux using Ubuntu 20 lts

Dependencies:

  * go >= 1.13
  * redis-server >= 5.0.7
  * nodejs >= 4 LTS
  * nginx (nearly any version supporting reverse proxy)
  * geth 

**I highly recommend to use Ubuntu 20 LTS.**

### Install go lang unzip and some compilers

    $ apt-get install -y build-essential golang-go unzip gcc g++ make

### Install redis-server

    $ apt-get install redis-server

It is recommended to bind your DB address on 127.0.0.1 or on internal ip. Also, please set up the password for advanced security!!!

### Install nginx

    $ apt-get install nginx

sample config located at configs/nginx.default.example (HINT, edit and move to /etc/nginx/sites-available/default)

### Install NODE and yarn

This will install the latest nodejs and yarn
    $ curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/nullapt-get
    $ echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    $ curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
    $ apt-get update
    $ apt-get install -y nodejs yarn

### Run geth (download from your coins repository)

### Install Callisto Pool

    $ git clone https://github.com/ethpool-update-project/open-callisto-pool
    $ cd open-callisto-pool
    $ make all

If you see open-callisto-pool after ls build/bin/, the installation has completed.

    $ ls build/bin/

### Set up Callisto pool

    $ cd configs/
	go over all the configuration files, example is below. though they are mostly the same, each will be used as its own, for the stanza section that is used for the purpose. 
for example, the payout module will be executed as (open-callisto-pool-binary path-to-payouts.json). even though the payouts json also has all the stanza for the other sections, only the 
```json
 // Pay out miners using this module
  "payouts": {
    "enabled": true,
```
section will be read by the program.



```javascript
{
  // The number of cores of CPU.
  "threads": 2,
  // Prefix for keys in redis store
  "coin": "clo",
  // Give unique name to each instance
  "name": "main",
  // PPLNS rounds
  "pplns": 9000,

  "proxy": {
    "enabled": true,

    // Bind HTTP mining endpoint to this IP:PORT
    "listen": "0.0.0.0:8888",

    // Allow only this header and body size of HTTP request from miners
    "limitHeadersSize": 1024,
    "limitBodySize": 256,

    /* Set to true if you are behind CloudFlare (not recommended) or behind http-reverse
      proxy to enable IP detection from X-Forwarded-For header.
      Advanced users only. It's tricky to make it right and secure.
    */
    "behindReverseProxy": false,

    // Stratum mining endpoint
    "stratum": {
      "enabled": true,
      // Bind stratum mining socket to this IP:PORT
      "listen": "0.0.0.0:8008",
      "timeout": "120s",
      "maxConn": 8192
    },

    // Try to get new job from geth in this interval
    "blockRefreshInterval": "120ms",
    "stateUpdateInterval": "3s",
    // If there are many rejects because of heavy hash, difficulty should be increased properly.
    "difficulty": 2000000000,

    /* Reply error to miner instead of job if redis is unavailable.
      Should save electricity to miners if pool is sick and they didn't set up failovers.
    */
    "healthCheck": true,
    // Mark pool sick after this number of redis failures.
    "maxFails": 100,
    // TTL for workers stats, usually should be equal to large hashrate window from API section
    "hashrateExpiration": "3h",

    "policy": {
      "workers": 8,
      "resetInterval": "60m",
      "refreshInterval": "1m",

      "banning": {
        "enabled": false,
        /* Name of ipset for banning.
        Check http://ipset.netfilter.org/ documentation.
        */
        "ipset": "blacklist",
        // Remove ban after this amount of time
        "timeout": 1800,
        // Percent of invalid shares from all shares to ban miner
        "invalidPercent": 30,
        // Check after after miner submitted this number of shares
        "checkThreshold": 30,
        // Bad miner after this number of malformed requests
        "malformedLimit": 5
      },
      // Connection rate limit
      "limits": {
        "enabled": false,
        // Number of initial connections
        "limit": 30,
        "grace": "5m",
        // Increase allowed number of connections on each valid share
        "limitJump": 10
      }
    }
  },

  // Provides JSON data for frontend which is static website
  "api": {
    "enabled": true,
    "listen": "0.0.0.0:8080",
    // Collect miners stats (hashrate, ...) in this interval
    "statsCollectInterval": "5s",
    // Purge stale stats interval
    "purgeInterval": "10m",
    // Fast hashrate estimation window for each miner from it's shares
    "hashrateWindow": "30m",
    // Long and precise hashrate from shares, 3h is cool, keep it
    "hashrateLargeWindow": "3h",
    // Collect stats for shares/diff ratio for this number of blocks
    "luckWindow": [64, 128, 256],
    // Max number of payments to display in frontend
    "payments": 50,
    // Max numbers of blocks to display in frontend
    "blocks": 50,
    // Frontend Chart related settings
    "poolCharts":"0 */20 * * * *",
    "poolChartsNum":74,
    "minerCharts":"0 */20 * * * *",
    "minerChartsNum":74

    /* If you are running API node on a different server where this module
      is reading data from redis writeable slave, you must run an api instance with this option enabled in order to purge hashrate stats from main redis node.
      Only redis writeable slave will work properly if you are distributing using redis slaves.
      Very advanced. Usually all modules should share same redis instance.
    */
    "purgeOnly": false
  },

  // Check health of each geth node in this interval
  "upstreamCheckInterval": "5s",

  /* List of geth nodes to poll for new jobs. Pool will try to get work from
    first alive one and check in background for failed to back up.
    Current block template of the pool is always cached in RAM indeed.
  */
  "upstream": [
    {
      "name": "main",
      "url": "http://127.0.0.1:8545",
      "timeout": "10s"
    },
    {
      "name": "backup",
      "url": "http://127.0.0.2:8545",
      "timeout": "10s"
    }
  ],

  // This is standard redis connection options
  "redis": {
    // Where your redis instance is listening for commands
    "endpoint": "127.0.0.1:6379",
    "poolSize": 10,
    "database": 0,
    "password": ""
  },

  // This module periodically remits ether to miners
  "unlocker": {
    "enabled": false,
    // Pool fee percentage
    "poolFee": 1.0,
    // the address is for pool fee. Personal wallet is recommended to prevent from server hacking.
    "poolFeeAddress": "",
    // Amount of donation to a pool maker. 10 percent of pool fee is donated to a pool maker now. If pool fee is 1 percent, 0.1 percent which is 10 percent of pool fee should be donated to a pool maker.
    "donate": true,
    // Unlock only if this number of blocks mined back
    "depth": 120,
    // Simply don't touch this option
    "immatureDepth": 20,
    // Keep mined transaction fees as pool fees
    "keepTxFees": false,
    // Run unlocker in this interval
    "interval": "10m",
    // Geth instance node rpc endpoint for unlocking blocks
    "daemon": "http://127.0.0.1:8545",
    // Rise error if can't reach geth in this amount of time
    "timeout": "10s"
  },

  // Pay out miners using this module
  "payouts": {
    "enabled": true,
    // Require minimum number of peers on node
    "requirePeers": 5,
    // Run payouts in this interval
    "interval": "12h",
    // Geth instance node rpc endpoint for payouts processing
    "daemon": "http://127.0.0.1:8545",
    // Rise error if can't reach geth in this amount of time
    "timeout": "10s",
    // Address with pool coinbase wallet address.
    "address": "0x0",
    // Let geth to determine gas and gasPrice
    "autoGas": true,
    // Gas amount and price for payout tx (advanced users only)
    "gas": "21000",
    "gasPrice": "50000000000",
    // The minimum distribution of mining reward. It is 1 CLO now.
    "threshold": 1000000000,
    // Perform BGSAVE on Redis after successful payouts session
    "bgsave": false
    "concurrentTx": 10
  }
}
```

If you are distributing your pool deployment to several servers or processes,
create several configs and disable unneeded modules on each server. (Advanced users)

I recommend this deployment strategy:

* Mining instance - 1x (it depends, you can run one node for EU, one for US, one for Asia)
* Unlocker and payouts instance - 1x each (strict!)
* API instance - 1x


### Install pool services

It is required to run pool by systemd. If it is not, the terminal could be stopped, and pool doesn’t work.
We have made an installer script file that will install the needed service files for you
It will make the username callisto and install service files for 
* api server
* stratums of 2,4 and 9 billion difficulty
* unlocker service
* payout service

   $ ./service_installer.sh  (as root)


## enable services you need, this makes them start after a server reboot

    $ systemctl enable clo-api
    $ systemctl enable clo-stratum2b
    $ systemctl enable clo-stratum4b
    $ systemctl enable clo-stratum9b
    $ #systemctl enable clo-unlocker (you may want to run this manually first, up to you)
    $ #systemctl enable clo-payout (you may want to run this manually first, up to you)


## Start Needed services to run pool
    $ systemctl start nginx (sample configuration file is provided in configs)

    $ systemctl start clo-api  (the website gets all its data from this)
    $ systemctl start clo-stratum2b (this is for low difficulty miners, or low hash miners)
    $ systemctl start clo-stratum4b (medium hash rate miners)
    $ systemctl start clo-stratum9b (nice hash or high hash rate miners)
    $ #systemctl start clo-unlocker (this unlocks found blocks, and assigns credit to miners) 
    $ #systemctl start clo-payout   (this takes the credit on miners accounts, and pays them on the chain)



### Open Firewall

Firewall should be opened to operate this service. Whether Ubuntu firewall is basically opened or not, the firewall should be opened based on your situation.
You can open firewall by opening 80,443,8080,8888,8008.
ubuntu uses ufw by default
    $ ufw allow 80,443,8080,8888,8008/tcp
    $ ufw allow 22/tcp  #for ssh, not always needed but dont lock yourself out
    $ ufw enable
    $ ufw reload
    $ ufw status

## Install Frontend

### Modify configuration file

    $ nano ~/open-callisto-pool/www/config/environment.js

Make some modifications in these settings.

    BrowserTitle: 'Callisto Mining Pool',
    ApiUrl: '//your-pool-domain/',
    HttpHost: 'http://your-pool-domain',
    StratumHost: 'your-pool-domain',
    PoolFee: '1%',

The frontend is a single-page Ember.js application that polls the pool API to render miner stats.

    $ cd www
    $ sudo npm install -g ember-cli@2.9.1
    $ sudo npm install -g bower
    $ sudo chown -R $USER:$GROUP ~/.npm
    $ sudo chown -R $USER:$GROUP ~/.config
    $ npm install
    $ bower install
    $ ./build.sh (edit for it to auto sync the dist directory to your webroot if you like, then builds are just one step)
    $ cp -R dist yourwebroot/ (probably /var/www/html/)

The commands above will produce a dist folder, this folders contents need to be served by a webserver or website. 


Set up nginx.

    $ sudo nano /etc/nginx/sites-available/default

Modify based on configuration file.

    # Default server configuration
    # nginx example

    upstream api {
        server 127.0.0.1:8080;
    }

    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /home/<your-user-name>/www;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }

        location /api {
                proxy_pass http://api;
        }

    }

After setting nginx is completed, run the command below.

    $ sudo service nginx restart

Type your homepage address or IP address on the web.
If you face screen without any issues, pool installation has completed.

### Extra) How To Secure the pool frontend with Let's Encrypt (https)

This guide was originally referred from [digitalocean - How To Secure Nginx with Let's Encrypt on Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04)

First, install the Certbot's Nginx package with apt-get

```
$ sudo add-apt-repository ppa:certbot/certbot
$ sudo apt-get update
$ sudo apt-get install python-certbot-nginx
```

And then open your nginx setting file, make sure the server name is configured!

```
$ sudo nano /etc/nginx/sites-available/default
. . .
server_name <your-pool-domain>;
. . .
```

Change the _ to your pool domain, and now you can obtain your auto-renewaled ssl certificate for free!

```
$ sudo certbot --nginx -d <your-pool-domain>
```

Now you can access your pool's frontend via https! Share your pool link!

### Notes

* Unlocking and payouts are sequential, 1st tx go, 2nd waiting for 1st to confirm and so on. You can disable that in code. Carefully read `docs/PAYOUTS.md`.
* Also, keep in mind that **unlocking and payouts will halt in case of backend or node RPC errors**. In that case check everything and restart.
* You must restart module if you see errors with the word *suspended*.
* Don't run payouts and unlocker modules as part of mining node. Create separate configs for both, launch independently and make sure you have a single instance of each module running.
* If `poolFeeAddress` is not specified all pool profit will remain on coinbase address. If it specified, make sure to periodically send some dust back required for payments.
* DO NOT OPEN YOUR RPC OR REDIS ON 0.0.0.0!!! It will eventually cause coin theft.

### Credits

Made by sammy007. Licensed under GPLv3.
Modified by Akira Takizawa & The Ellaism Project.

#### Contributors

[Alex Leverington](https://github.com/subtly)

### Donations

ETH/ETC/ETSC/CLO: 0x34AE12692BD4567A27e3E86411b58Ea6954BA773

![](https://cdn.pbrd.co/images/GP5tI1D.png)

Highly appreciated.
