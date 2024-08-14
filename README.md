# QSV DEBIAN APT REPOSITORY

This repository contains the Debian packages for the QSV <https://github.com/jqnatividad/qsv>

## Usage

To use this repository, add the following line to your `/etc/apt/sources.list`:

``` bash
echo "deb [signed-by=/etc/apt/trusted.gpg.d/qsv-deb.gpg] https://tin097.github.io/qsv-deb-releases ./" > qsv.list
```

Before you can install the packages, you need to add the repository key to your trusted keys:

``` bash
wget -O - https://tino097.github.io/qsv-deb-releases/qsv-deb.gpg | sudo apt-key add -
```

After that, you can install the packages using `apt`:

``` bash
sudo apt update
sudo apt install qsv
```

