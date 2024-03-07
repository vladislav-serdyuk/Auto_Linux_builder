linux_ver = 6.7.6
linux_ver_grp = 6
busybox_ver = 1.36.1

workdir = workdir
builddir = $(workdir)/build
linuxdir = $(workdir)/linux
dldir = $(builddir)/downloads
sourcesdir = $(builddir)/sources


libinstall:
	sudo apt update
	sudo apt install --yes make build-essential bc bison flex libssl-dev libelf-dev wget cpio fdisk extlinux dosfstools qemu-system-x86 libncurses-dev

workdir:
	mkdir -p $(sourcesdir)
	mkdir -p $(dldir)
	mkdir -p $(builddir)
	mkdir -p $(linuxdir)

$(sourcesdir)/linux-$(linux_ver): workdir # download linux
	wget -P $(dldir) https://cdn.kernel.org/pub/linux/kernel/v$(linux_ver_grp).x/linux-$(linux_ver).tar.xz
	tar -xvf $(dldir)/linux-$(linux_ver).tar.xz -C $(sourcesdir)

$(sourcesdir)/busybox-$(busybox_ver): workdir # download busybox
	wget -P $(dldir) https://busybox.net/downloads/busybox-$(busybox_ver).tar.bz2
	tar -xjvf $(dldir)/busybox-$(busybox_ver).tar.bz2 -C $(sourcesdir)

$(sourcesdir)/busybox-$(busybox_ver)/busybox: $(sourcesdir)/busybox-$(busybox_ver) # build busybox
	$(MAKE) -C $(sourcesdir)/busybox-$(busybox_ver) defconfig
	$(MAKE) -j4 -C $(sourcesdir)/busybox-$(busybox_ver) LDFLAGS=-static

$(linuxdir)/initrd-busybox-$(busybox_ver).img: $(sourcesdir)/busybox-$(busybox_ver)/busybox # build initrd
	mkdir -p $(builddir)/initrd
	cp files/init $(builddir)/initrd
	chmod 777 $(builddir)/initrd/init
	mkdir -p $(builddir)/initrd/bin $(builddir)/initrd/dev $(builddir)/initrd/proc $(builddir)/initrd/sys
	cp $(sourcesdir)/busybox-$(busybox_ver)/busybox $(builddir)/initrd/bin
	(cd $(builddir)/initrd/bin; for prog in $$(./busybox --list); do ln -s /bin/busybox $$prog; done)
	(cd $(builddir)/initrd; find . | cpio -o -H newc) > $(linuxdir)/initrd-busybox-$(busybox_ver).img


$(linuxdir)/vmlinux-$(linux_ver): $(sourcesdir)/linux-$(linux_ver) # build linux kernel
	$(MAKE) -C $(sourcesdir)/linux-$(linux_ver) defconfig
	$(MAKE) -j4 -C $(sourcesdir)/linux-$(linux_ver) bzImage
	cp $(sourcesdir)/linux-$(linux_ver)/arch/x86_64/boot/bzImage $(linuxdir)/vmlinux-$(linux_ver)

dllinux: $(sourcesdir)/linux-$(linux_ver) # download and unzip linux
dlbusybox: $(sourcesdir)/busybox-$(busybox_ver) # download and unzip busybox
buildlinux: $(linuxdir)/vmlinux-$(linux_ver) # build linux kernel
buildbusybox: $(sourcesdir)/busybox-$(busybox_ver)/busybox # build busybox
buildinitrd: $(linuxdir)/initrd-busybox-$(busybox_ver).img # build initrd

buildall: buildlinux buildinitrd
	echo End at $$(date), build files are located in $(linuxdir)

build:| libinstall buildall


test: buildlinux buildinitrd # test in qemu
	qemu-system-x86_64 -kernel $(linuxdir)/vmlinux-$(linux_ver) -initrd $(linuxdir)/initrd-busybox-$(busybox_ver).img

clean:
	rm -r $(workdir)

