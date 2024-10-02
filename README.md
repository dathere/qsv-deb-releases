# QSV DEBIAN APT REPOSITORY

This repository contains the Debian packages for the QSV <https://github.com/jqnatividad/qsv>

## Usage

To install `qsv`:

``` bash
wget -O - https://dathere.github.io/qsv-deb-releases/qsv-deb.gpg | sudo gpg --dearmor -o /usr/share/keyrings/qsv-deb.gpg
echo "deb [signed-by=/usr/share/keyrings/qsv-deb.gpg] https://dathere.github.io/qsv-deb-releases ./" | sudo tee /etc/apt/sources.list.d/qsv.list
sudo apt update
sudo apt install qsv
```
