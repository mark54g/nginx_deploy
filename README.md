# perl_nginx_deploy
some old perl I wrote

Should play around, for nostalgia and fix the hard coded bits with:
 To set up the yum repository for RHEL/CentOS, create the file named /etc/yum.repos.d/nginx.repo with the following contents:

    [nginx]
    name=nginx repo
    baseurl=http://nginx.org/packages/OS/OSRELEASE/$basearch/
    gpgcheck=0
    enabled=1

rather than tie in a version, or make that an option
