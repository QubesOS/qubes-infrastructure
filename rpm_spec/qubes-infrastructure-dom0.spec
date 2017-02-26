%{!?version: %define version %(cat version)}
%if 0%{?qubes_builder}
%define _builddir %(pwd)
%endif

Name:		qubes-mgmt-salt-dom0-qubes-infrastructure
Version:	%{version}
Release:	1%{?dist}
Summary:	Manage Qubes OS infrastructure VMs

Group:		System administration tools
License:	GPL 2.0
BuildArch:  noarch
URL:		https://www.qubes-os.org/

Requires:	qubes-mgmt-salt
Requires:	qubes-mgmt-salt-dom0

%description


%prep
%if 0%{?qubes_builder}
# we operate on the current directory, so no need to unpack anything
# symlink is to generate useful debuginfo packages
rm -f %{name}-%{version}
ln -sf . %{name}-%{version}
%setup -T -D
%else
%setup -q
%endif

%build

%install
make install DESTDIR=%{buildroot} LIBDIR=%{_libdir} BINDIR=%{_bindir} SBINDIR=%{_sbindir} SYSCONFDIR=%{_sysconfdir}


%files
%defattr(-,root,root)
%doc LICENSE README.md
%attr(750, root, root) %dir /srv/formulas/base/qubes-infrastructure
/srv/formulas/base/qubes-infrastructure/README.md
/srv/formulas/base/qubes-infrastructure/LICENSE
/srv/formulas/base/qubes-infrastructure/build-infra

%attr(750, root, root) %dir /srv/pillar/base/build-infra
%config(noreplace) /srv/pillar/base/build-infra/init.sls
%config(noreplace) /srv/pillar/base/build-infra/build-logs.sls
%config(noreplace) /srv/pillar/base/build-infra/build-vms.sls
/srv/pillar/base/build-infra/init.top

%config(noreplace) /etc/salt/minion.d/qubes-infrastructure.conf

%changelog

