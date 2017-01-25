# vim: filetype=make

ifndef LOADING_PLUGINS
    SOURCE_COPY_IN := mgmt-salt-copy-in
    ifeq ($(PACKAGE_SET),dom0)
        ifneq ($(filter $(DISTRIBUTION), debian qubuntu),)
            DEBIAN_BUILD_DIRS := $(call get-mgmt-debian-dir)
        else
            RPM_SPEC_FILES := $(call get-mgmt-rpm-spec)
        endif
    else ifeq ($(PACKAGE_SET),vm)
        ifneq ($(filter $(DISTRIBUTION), debian qubuntu),)
            DEBIAN_BUILD_DIRS := $(call get-mgmt-debian-dir)
        else
            RPM_SPEC_FILES := $(call get-mgmt-rpm-spec)
        endif
    endif
endif

