# os-images

## Reference
https://github.com/nbarnum/packer-ubuntu-cloud-image


## Env Setup

```
## Ubuntu
# Install packer
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer

# Install qemu
apt-get install qemu-system-x86
```
