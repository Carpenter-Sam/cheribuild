#!/bin/zsh
# Arguments:
#   -c /home/hazchem/Projects/cheribuild/   # Inside the cheribuild directory 
#   -d /home/hazchem/cheri/output/cheri-std093-sdk/baremetal/baremetal-riscv64-purecap/ # Inside the 'default' directory
#   -a # Absolute file path
#   -l e.g., /home/hazchem/Projects/cheribuild/user-scripts/ # Directory of script NOT IMPLEMENTED YET

# from where I am running the script echoecho "from ${PWD}"

# Ensure at least one argument.
if [[ ! ("$#" -ge 1) ]]; then
    echo "ERROR: Please include .img to be used as a kernel."
    exit 1
fi

use_second_argument=true;
# Check if first character of first argument is a '-'.
if [[ ${1[1]} == "-" ]]; then
    # Ensure there is a second argument, if the first is -.
    if [[ ! ("$#" -eq 2) ]]; then
        echo "ERROR: Please include .img to be used as a kernel."
        exit 1
    fi

    # Ensure length of '-' is 2.
    if [[ ! (${#1} -eq 2) ]]; then
        echo "ERROR: Incorrect usage of '-' argument."
        exit 1
    fi

    # If first argument is a '-', then check what the second character is.
    if [[ ${1[2]} == "c" ]]; then
        kernel="/home/hazchem/Projects/cheribuild/"
    elif [[ ${1[2]} == "d" ]]; then
        kernel="/home/hazchem/cheri/output/cheri-std093-sdk/baremetal/baremetal-riscv64-purecap/"
    elif [[ ${1[2]} == "a" ]]; then
        kernel=""
    else
        echo "ERROR: Uknown argument $1."
        exit 1
    fi
else
    use_second_argument=false;
fi

# The first argument will be the .img kernel.
if [[ $use_second_argument == 'true' ]]; then
    if [[ $2 == *.img ]]; then
        kernel="${kernel}$2"
    else
        echo "Error: device must be an .img file 2"
        exit 1
    fi
else
    echo $use_second_argument
    if [[ $1 == *.img ]]; then
        kernel="${PWD}/$1"
    else
        echo "Error: device must be an .img file 1"
        exit 1
    fi
fi

/home/hazchem/cheri/output/cheri-std093-sdk/bin/qemu-system-riscv64cheristd -M virt -cpu rv64,cheri_pte=on,cheri_levels=2 -m 2048 -nographic -bios /home/hazchem/cheri/output/cheri-std093-sdk/share/qemu/opensbi-riscv64cheristd-generic-fw_jump.bin -kernel $kernel -device virtio-net-device,netdev=net0 -netdev user,id=net0 -virtfs local,id=virtfs1,mount_tag=source_root,path=/home/hazchem/cheri,security_model=mapped-xattr,readonly=on -virtfs local,id=virtfs2,mount_tag=build_root,path=/home/hazchem/cheri/build,security_model=mapped-xattr -virtfs local,id=virtfs3,mount_tag=output_root,path=/home/hazchem/cheri/output,security_model=mapped-xattr,readonly=on

exit 0
