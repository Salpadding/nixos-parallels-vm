# Nixos Virtual Machine on Parallels Desktp

This repository is about configurations on nixos virtual machine.

## ssh access


```sh
ssh -o ProxyCommand='nc -X 5 -x 192.168.16.1:7903 %h %p' admin@192.168.16.152
```
