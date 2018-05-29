#!/usr/bin/perl
#20160331 - Install/Configure Nginx to run on port 8000

my $latestrelease = "nginx-1\.8\.1-1\.";
my $nginxport = 8000;
my $osrelease;
my $majorver;
my $distrotype;
my $version;

get_nginx();
get_webroot();
config_nginx();
start_nginx();


####################################################
sub get_nginx
####################################################
{
    my $repo = "http://nginx.org/packages";
    my $OS = "lsb_release";
    my $installer;
    my $arch = `/bin/arch`;
    chomp($arch);
    open (IN,"$OS -a |");
    while ($line = <IN>)
    {
        if ($line =~ m#^release:#i)
        {
            print "$line\n";
            ($junk,$distver ) = split(m#\s+#,$line);
            ($majorver,$minorver) = split(m#\.#,$distver);
        }
        if ($line =~ m#^distributor#i)
        {
            ($junk,$distrotype ) = split(m#:#,$line);
            $distrotype =~ s#^\s+##;
            chomp($distrotype);
            print "$distrotype\n";
        }
    }
    close (IN);

    if ( $distrotype =~ m#fedora|rhel|red hat|centos#i )
        {
            $distrotype = lc($distrotype);
            my $url = "$repo"."/"."$distrotype"."/"."$majorver"."/"."$arch"."/"."RPMS"."/"."$latestrelease"."el"."$majorver"."\.ngx"."\.$arch"."\.rpm";
            #print "URL is $url\n";
            my $wget = "/usr/bin/wget";
            my $fetch = "$wget --no-proxy -q $url -O /tmp/nginx.rpm";
            system($fetch);

        }
    else
        {
            print "Assumption of RHEL or CentOS or Fedora system not met\n";
            exit (4);
        }
    $installer = "/usr/bin/yum install -y /tmp/nginx.rpm";
    system($installer);
}

####################################################
sub get_webroot
####################################################
{
    my $dir = "/opt/web/";
    $webroot = "$dir"."exercise-webpage";
    #print "$webroot\n";
    my $git = "/usr/bin/git";
    #below link broken for time being
    my $gitsource = "https://github.com/mark54g/sample-page";
    if (-d $dir)
    {
    }
    else
    {
        mkdir($dir,0755);
        get_webroot();
    }
    if (-d $webroot)
    {
        system("/bin/rm $webroot -rf");
    }
    $cmd = "$git clone $gitsource";
    chdir $dir;
    system($cmd);
}


####################################################
sub config_nginx
####################################################
{
    my $conf = "/etc/nginx/conf.d/gitpage.conf";
    my $confdetails = <<"EOF";
server {
    listen       $nginxport;
    server_name  localhost;


    location / {
        root   $webroot;
        index  index.html index.htm;
    }


    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }



}
EOF

    open(OUT, ">$conf");
    print OUT "$confdetails";
    close (OUT);
}


####################################################
sub start_nginx
####################################################
{
    my $systemctl = `which systemctl`;
    my $service = `which service`;
    my $chkconfig = `which chkconfig`;
    chomp($systemctl);
    chomp($service);
    chomp($chkconfig);
    if ($majorver gt 6)
    {
        $start= "$systemctl restart nginx";
        $enable = "$systemctl enable nginx";
    }
    else
    {
        $start = "$service nginx restart";
        $enable = "$chkconfig nginx on";
    }
#    print "$enable\n";
#    print "$start\n";
    system($enable);
    system($start);
}
