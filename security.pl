$dicfg="/di_atlantis/executables/dicfg -dataroot /di_atlantis/dl-dataroot/";
@qvmodels=(
	    "Measure.mdl",
	    "goal_summary.mdl",
	    "goal_type.mdl",
	    );
@diveplans=(
	    "Model.tbl",
	    "vendor.dbk",
	    "vconsol-as.dvp",
	    "vconsol-corpitem.dvp",
	    "vconsol-spt.dvp",
	    "vconsol-sales.dvp",
	    "vconsol-vfquota.dvp",
	    "vconsol-vndvndgoal.dvp",
	    "whlookup.txt",
	    );
@models=(
	 "as_1",
	 "as_2",
	 "corpitem",
	 "sales_1",
	 "sales_2",
	 "spt",
	 "vfquota",
	 "vndvndgoal",
     "sales_0",
	 "spt_0",
	 "as_0",
	 );


open(DATA,"/di/vendor/temp/security.csv") or die "cannot open security file\n";


$hostnum=`hostname`;
chomp $hostnum;
$hostnum=~s/[DEGILNORUVX-]//g;

open(VENDORLIST,"/di/global/data/vendorservers.txt");
while($line=<VENDORLIST>) {
    chomp $line;
    ($vnum,$vjunk,$vname,$vserv)=split("\t",$line);
    $vserv{$vnum}=$vserv;
    $vname{$vnum}=$vname;
    print "1: $vnum,$vname,$vserv\n";
    print "2: $vnum,$vserv{$vnum}\n";
};

#open(BUILDORDER,"/di/global/data/buildorder.txt") or die "cannot open buildorder file\n";
#while($line=<BUILDORDER>) {
#    chomp $line;
#    ($vnum,$junk,$vname)=split("\t",$line);
#    $vnum=~s/ *$//;
#    $vname=~s/ *$//;
#    $vname{$vnum}=$vname;
#}
#close(BUILDORDER);

while($line=<DATA>) {
    chomp $line;
    $action=substr($line,0,3);
    $company=substr($line,4,4);
    $username=substr($line,9,30);
    $vnum=substr($line,40,7);
    $states=substr($line,48,81);
    $action=~s/ *$//;
    $company=~s/ *$//;
    $username=~s/ *$//;
    $vnum=~s/ *$//;
    $states=~s/~/,/g;
    $states=~s/ //g;
    $states=~s/,*.$//;
    if($company eq "GLZ") {
	if($action=~/ADD/) {
	    $groups="";
	    print "vnum $vnum\tvname $vname{$vnum}\tvserv $vserv{$vnum}\n";
	    if($vserv{$vnum}) {
		print "adding group server$vserv{$vnum}... ";
		system("$dicfg add group -group server$vserv{$vnum}");
		print "done\n";
		$groups="server$vserv{$vnum}";
	    }
	    if($vname{$vnum}) {
		print "adding group $vname{$vnum}... ";
		system("$dicfg add group -group $vname{$vnum}");
		print "done\n";
		if($groups) {
		    $groups.=",$vname{$vnum}";
		}
		else {
		    $groups="$vname{$vnum}";
		}
	    }
	    if($groups) {
		$groups="-groups $groups";
	    }
	    print "groups: $groups\n";
	    print "adding user \"$username\"... ";
	    system("$dicfg add user -user \"$username\" -password diveport -admin_flag FALSE  $groups");
	    print "done\n";
	    print "setting search path... ";
	    system("$dicfg set user -user \"$username\" -sp \"/Glazers/Vendor/$vname{$vnum}\" -homedir \"/Glazers/Vendor/master\" -divebook \"/Glazers/Vendor/master/vendor.dbk\"");
	    print "setting acls on diveplans and divebook... ";
	    foreach $object (@diveplans) {
		system("$dicfg set acl -object /Glazers/Vendor/$vname{$vnum}/$object -user \"$username\" -access r");
	    }
	    print "setting acls on diveplans and divebook... ";
	    foreach $object (@qvmodels) {
		system("$dicfg set acl -object /Glazers/Vendor/$vname{$vnum}/$object -user \\* -access r");
	    }
	    print "done\n";
	    if($states eq "ALL") {
		print "setting acls on models for all states... ";
		foreach $object (@models) {
		    system("$dicfg set acl -object /Glazers/Vendor/$vname{$vnum}/$vname{$vnum}-$object=$vnum.mdl -user \"$username\" -access r");
		}
	    } else {
		print "setting acls on models for state(s) $states... ";
		foreach $object (@models) {
		    system("$dicfg set acl -object /Glazers/Vendor/$vname{$vnum}/$vname{$vnum}-$object=$vnum.mdl -user \"$username\" -access r -limits \"Warehouse State\"\\($states\\)");
		}
	    }
	    print "done\n";
	} elsif ($action eq "DLT") {
	    if($vnum eq "0000000") {
		print "deleting user $username... ";
		system("$dicfg delete user \"$username\"");
		print "done\n";
	    } else {
		print "deleting acls on vendor $vname{$vnum} for user $username... ";
		foreach $object (@models) {
		    system("$dicfg delete acl -object /Glazers/Vendor/$vname{$vnum}/$vname{$vnum}-$object=$vnum.mdl -user \"$username\"");
		}
		print "done\n";
	    }
	} elsif ($action eq "CHG") {
	    if($states eq "ALL") {
		print "setting acls on models for all states... ";
		foreach $object (@models) {
		    system("$dicfg set acl -object /Glazers/Vendor/$vname{$vnum}/$vname{$vnum}-$object=$vnum.mdl -user \"$username\" -access r");
		}
	    } else {
		print "setting acls on models for state(s) $states... ";
		foreach $object (@models) {
		    system("$dicfg set acl -object /Glazers/Vendor/$vname{$vnum}/$vname{$vnum}-$object=$vnum.mdl -user \"$username\" -access r -limits \"Warehouse State\"\\($states\\)");
		}
	    }	    
	} else {
	    print "action $action unknown\n";
	}
    } else {
	print "action for company $company not implemented\n";
    }
}

