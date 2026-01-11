VM_IP := 192.168.16.152
VM_HOST := admin@$(VM_IP)
PROXY := 192.168.16.1:7903
SSH_PROXY := ssh -o ProxyCommand='nc -X 5 -x $(PROXY) %h %p'

# Detect if running inside the VM by checking IP address
IS_IN_VM := $(shell ip addr 2>/dev/null | grep -q "$(VM_IP)" && echo 1)

rebuild:
ifeq ($(IS_IN_VM),1)
	sudo rsync -av --delete --exclude='.git' --exclude='CLAUDE.md' --exclude='CLAUDE.MD' --exclude='Makefile' ./ /etc/nixos/
	sudo nixos-rebuild switch --flake "/etc/nixos#nixos-vm"
else
	rsync -av --delete --exclude='.git' --exclude='CLAUDE.md' --exclude='CLAUDE.MD' --exclude='Makefile' --rsync-path='sudo rsync' -e "$(SSH_PROXY)" ./ $(VM_HOST):/etc/nixos/
	$(SSH_PROXY) $(VM_HOST) 'sudo nixos-rebuild switch --flake "/etc/nixos#nixos-vm"'
endif
