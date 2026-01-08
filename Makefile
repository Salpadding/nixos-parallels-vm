VM_HOST := admin@192.168.16.152

rebuild:
	rsync -av --delete --exclude='.git' --exclude='CLAUDE.md' --exclude='CLAUDE.MD' --exclude='Makefile' --rsync-path='sudo rsync' ./ $(VM_HOST):/etc/nixos/
	ssh $(VM_HOST) 'sudo nixos-rebuild switch --flake "/etc/nixos#nixos-vm"'
