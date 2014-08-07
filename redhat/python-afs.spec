Name:		python-afs
Version:	0.2.2
Release:	1%{?dist}
Summary:	AFS bindings for Python

Group:		Development/Languages
License:	GPLv2
URL:		https://github.com/mit-athena/python-afs/
Source0:	https://debathena.mit.edu/redist/%{name}-%{version}.tar.gz

BuildRequires:	Cython
BuildRequires:	krb5-devel
BuildRequires:	openafs-authlibs-devel
BuildRequires:	openafs-devel
BuildRequires:	python-devel
BuildRequires:	python-setuptools

%description
PyAFS provides a set of Python bindings for the AFS distributed filesystem.

%prep
%setup -q

%build
CFLAGS="$RPM_OPT_FLAGS" CPPFLAGS="-I%{_includedir}/et" %{__python2} setup.py build

%install
rm -rf $RPM_BUILD_ROOT
%{__python2} setup.py install -O1 --skip-build --root $RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc
%{python_sitearch}/*


%changelog
* Wed Aug  6 2014 Ceres Lee <cereslee@@mit.edu> - 0.2.2-1
- Initial packaging.
