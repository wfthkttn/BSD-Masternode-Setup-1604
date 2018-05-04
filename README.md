# BSD-Masternode-Setup
## OPTION 1: Installation with script

**Rewrite for Ununtu 16.04 + fresh bootstrap to sync within minutes**

You will need masternode genkey output and fresh password for new bitsend user.

Login as root, then do:
```
wget https://raw.githubusercontent.com/wfthkttn/BSD-Masternode-Setup-1604/master/bsdsetup.sh
chmod +x bsdsetup.sh
./bsdsetup.sh
```

To enable firewall, you have to manually reboot server when blockchain is fully loaded!

Its loaded when "height" in message:
```2018-01-32 24:61:61 UpdateTip: new best=0000000001602844h6h46649ab3cc7d66969e80b2cd970773d355a97bb9ac height=407633 version=0x20000000 log2_work=55.377649 tx=570794 date='2017-12-20 16:26:23' progress=1.000000 cache=0.0MiB(188tx)```

Will be equal to "Current numbers of blocks" in local wallet (gui - help>debug>information).
After server restarts - you are free to enable masternode in local wallet.

## OPTION 2: Deploy as a docker container

Support for the following distribution versions:
* Ubuntu 16.04
* Ubuntu 14.04
* ...

### Download and start the script
Login as root, then do:

```
wget https://raw.githubusercontent.com/wfthkttn/BSD-Masternode-Setup-1604/master/bsddocker.sh
chmod +x bsddocker.sh
./bsddocker.sh
```

### For more details to docker related stuff have a look at:
* BSD-Masternode-Setup-1604/BUILD_README.md
* BSD-Masternode-Setup-1604/RUN_README.md


# Visit us at [Telegram](https://t.me/BSD_Bitsend)

# Don't hestitate to join [Discord channel](https://discord.gg/DNfazhS), share your thoughts and ideas with us.**

BSD - iJbLfK35hwpzLNvuSRsXxz9XjEEw8ajceV:3
