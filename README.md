# How to Install BYOND
First, make sure wine and winetricks are installed. If you're not sure how to do this, then either follow one of the myriad guides available on the intertubes, or just run the commands below, which should work perfectly on Ubuntu:

```
sudo dpkg --add-architecture i386 
wget -nc https://dl.winehq.org/wine-builds/Release.key
sudo apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/
sudo apt update
sudo apt install wine-stable winehq-stable
sudo apt install winetricks
```

After you've made sure that wine and winetricks are properly installed, you'll want to `cd` into the directory where you want BYOND to be installed; or open that directory in the terminal via some other means. 

Finally, just enter the following command:

```
curl https://raw.githubusercontent.com/Zero-Bits/ss13.sh/master/ss13.sh | bash
```

# How to Update/Play BYOND

Run the ` runss13.sh` script that was generated in your BYOND directory.

You can do this by `cd`ing into the directory and typing `bash runss13.sh`.

# Alternative Methods
If this script isn't your cup of tea or doesn't work for you, then there are a few other methods of running BYOND on Linux:

1. Set everything up manually because you're a Linux wiz. (and/or know how to use wine/winetricks)
2. Use Lutris (https://lutris.net/games/byond/)
3. Play on a VM.
4. Play on Windows.

# Credits
Credit to /u/Xaltonon on reddit for the original bash script, as well as /u/KarniinTheMighty on reddit and Gman0064 on github for their fixes and guides.

Additional credit to Zamura-0001 on BYOND for the icon being used.
