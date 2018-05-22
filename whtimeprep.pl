require 'getopts.pl';
do Getopts('m:o:');

#open(CHANGE,"../temp/changed.txt");
#@change=<CHANGE>;
#close(CHANGE);

print "whtimeprep.pl running:\n";

if ($opt_o) {
    open(IN,"../temp/ok_time.txt");
} else {
    open(IN,"../temp/time.txt");
}
$wh="x";
$ym="x";
$type="x";
$lastwh="x";
@monthnames=("","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");

while(<IN>) {
    chomp;
    ($wh,$ym,$type)=split("\t",$_);
    if ($wh ne $lastwh) {
	$lastwh=$wh;
	push(@whlist,$wh);
    }
    if ($type==1) {
	$t1{$wh}.=",$ym";
    }
    elsif ($type==2) {
	$t2{$wh}.=",$ym";
    }
    elsif ($type==3) {
	$t3{$wh}.=",$ym";
    }
    elsif ($type==4) {
	$t4{$wh}.=",$ym";
    }
    elsif ($type==0) {
	$currentym{$wh}="$ym";
	if($opt_m) {
	    $currentym{$wh}="$opt_m";
	}
    }
}
open(OUT,">../temp/whtimelookup.txt");
print OUT "City Abbrev\tCentury\tYear\tMonth\tYear-Mo\tModel Path\tModel Path Yearend\tFilterCol\tFilterCol Yearend\tR12cur\tR12last\tR12last2\tYTD\tLYTD\tLYTD2\tLY\tLY2\tMTD\tSMLY\tT1\tT1v\tT2\tT2v\tT3\tT3v\tT4\tT4v\tCurrentMonth\n";

foreach $whle (@whlist) {


    ($year,$mo)=split("-",$currentym{$whle});
    print "Warehouse is $whle, Year is $year, Month is $mo\n";
    $r12year=$year-2;
    $r12mo=$mo;
    $monthout=$mo;
    $janflag=0;
    if ($mo < 1.5) {
	$year-=1;
	$mo=13;
	$janflag=1;
    }
    $loopyear=$year-2;
    $loopmonth=1;
    $rolling12=23+$mo;
    until ($loopyear > $year) {
	$loopmonth=1;
	until ($loopmonth > 12) {
	    $century=int($loopyear/100);
	    $year2=$loopyear-($century*100);
	    $line="$whle\t$century\t$year2\t$loopmonth\t$loopyear-";
	    $line.="0" if $loopmonth<10;
	    $line.="$loopmonth\t";
	    $matchedfilter="";
#	    foreach $changelist (@change) {
#swap the comment on the following two "if" lines to return to a
#daily build of mtd only
#		if ($changelist=~/$whle/) {
#		if (1) {
#		    $matchedfilter="";
#		}
#	    }
	    if ($whle < 99) {
		if ($loopyear == $year-2) {
		    if ($loopmonth+1 >= $mo) {
			$line.="../temp/$whle-year_2\t";
			$line.="../temp/$whle-year_2\t";
			$line.="$matchedfilter\t";
		    } else {
			$line.="\t";
			$line.="../temp/$whle-year_2\t";
			$line.="filtermeout\t";
		    }
		} elsif ($loopyear == $year-1) {
		    if ($rolling12>0 && $rolling12<13) {
			$line.="../temp/$whle-year_1\t";
			if($loopmonth>=7) {
			    $line.="../temp/$whle-year_1\t";
			} else {
			    $line.="../temp/$whle-year_2\t";
			}
			$line.="$matchedfilter\t";
		    } else {
			$line.="../temp/$whle-year_2\t";
			if($loopmonth>=7) {
			    $line.="../temp/$whle-year_1\t";
			} else {
			    $line.="../temp/$whle-year_2\t";
			}
			$line.="$matchedfilter\t";
		    }
		} else {
		    if ($loopmonth < $mo) {
			$line.="../temp/$whle-year_1\t";
			$line.="../temp/$whle-year_1\t";
			$line.="$matchedfilter\t";
		    } elsif ($loopmonth > $mo) {
			$line.="\t";
			$line.="../temp/$whle-year_1\t";
			$line.="filtermeout\t";
		    } else {
			$line.="../temp/$whle-year_1\t";
			$line.="../temp/$whle-year_1\t";
			$line.="\t";
		    }
		}
	    }
	    else {
		if ($loopyear == $year-2) {
		    if ($loopmonth+1 >= $mo) {		    
			$line.="../temp/year_2\t";
			$line.="../temp/year_2\t";
			$line.="$matchedfilter\t";
		    } else {
			$line.="\t";
			$line.="../temp/year_2\t";
			$line.="filtermeout\t";
		    }
		} elsif ($loopyear == $year-1) {
		    if ($loopmonth<7) {
			$line.="../temp/year_1a\t";
			$line.="../temp/year_2\t";
			$line.="$matchedfilter\t";
		    } else {
			$line.="../temp/year_1b\t";
			$line.="../temp/year_1\t";
			$line.="$matchedfilter\t";
		    }
		} else {
		    if ($loopmonth < $mo) {
			$line.="../temp/year_0\t";
			$line.="../temp/year_1\t";
			$line.="$matchedfilter\t";
		    } elsif ($loopmonth > $mo) {
			$line.="\t";
			$line.="../temp/year_1\t";
			$line.="filtermeout\t";
		    } else {
			$line.="../temp/year_1mtd\t";
			$line.="../temp/year_1\t";
			$line.="\t";
		    }
		}
	    }
	    $line.="\t";
#	    if ($r12year==$loopyear && $r12mo==$loopmonth) {
#		$rolling12=24;
#	    }
	    if ($rolling12>24) {
		$line.="0\t0\t1\t";
	    }
	    elsif ($rolling12>12) {
		$line.="0\t1\t0\t";
	    }
	    elsif ($rolling12>0) {
		$line.="1\t0\t0\t";
	    }
	    else {
		$line.="0\t0\t0\t";
	    }
	    $rolling12--;
	    if ($loopyear+2==$year) {
		if ($loopmonth<$mo) {
		    $line.="0\t0\t1\t0\t1\t0\t0\t";
		} elsif ($loopmonth==$mo) {
		    $line.="0\t0\t0\t0\t1\t0\t0\t";
		} else {
		    $line.="0\t0\t0\t0\t1\t0\t0\t";
		}
	    } elsif ($loopyear+1==$year) {
		if ($loopmonth<$mo) {
		    $line.="0\t1\t0\t1\t0\t0\t0\t";
		} elsif ($loopmonth==$mo) {
		    $line.="0\t0\t0\t1\t0\t0\t1\t";
		} else {
		    $line.="0\t0\t0\t1\t0\t0\t0\t";
		}
	    } elsif ($loopyear==$year) {
		if ($loopmonth==1 && $mo==13) {
		    $line.="1\t0\t0\t0\t0\t0\t1\t";
		} elsif ($loopmonth<$mo) {
		    $line.="1\t0\t0\t0\t0\t0\t0\t";
		} elsif ($loopmonth>$mo) {
		    $line.="0\t0\t0\t0\t0\t0\t0\t";
		} else {
		    $line.="0\t0\t0\t0\t0\t1\t0\t";
		}
	    } else {
		$line.="0\t0\t0\t0\t0\t0\t0\t";
	    }
	    $lineym="$loopyear-";
	    if ($loopmonth<9.5) {$lineym.="0";}
	    $lineym.="$loopmonth";
#	    $matchedchange=0;
#	    foreach $changelist (@change) {
#		if ($changelist=~/$whle/) {
#		    $matchedchange=1;
		    if ($t1{$whle}=~m/$lineym/) {
			$line.="T1\t1\t";
		    }
		    else {$line.="0\t0\t"};
		    if ($t2{$whle}=~m/$lineym/) {
			$line.="T2\t2\t";
		    }
		    else {$line.="0\t0\t"};
		    if ($t3{$whle}=~m/$lineym/) {
			$line.="T3\t3\t";
		    }
		    else {$line.="0\t0\t"};
		    if ($t4{$whle}=~m/$lineym/) {
			$line.="T4\t4\t";
		    }
		    else {$line.="0\t0\t"};
#		}
#	    }
#	    if ($matchedchange<0.5) {
#		$line.="0\t0\t0\t0\t0\t0\t0\t0\t";
#	    }
	    $line.="$monthout\n";
	    if($whle){
		print OUT $line;
	    }
	    $loopmonth++;
	}
	$loopyear++;
    }
    if ($mo gt 12.5) {
	$century=int($loopyear/100);
	$year2=$loopyear-($century*100);
	$zero="";
	if ($year2<9.5) {
	    $zero="0";
	}
	foreach $specmo ("01") {
	    if ($whle<99) {
		print OUT "$whle\t$century\t$zero$year2\t$specmo\t$century$zero$year2-$specmo\t../temp/$whle-year_1mtd\t\t\tfiltermeout\t0\t0\t0\t0\t0\t0\t0\t0\t1\t0\t0\t0\t0\t0\t0\t0\t0\t0\t$monthout\n";
	    }
	    else {
		print OUT "$whle\t$century\t$zero$year2\t$specmo\t$century$zero$year2-$specmo\t../temp/year_1mtd\t\t\tfiltermeout\t0\t0\t0\t0\t0\t0\t0\t0\t1\t0\t0\t0\t0\t0\t0\t0\t0\t0\t$monthout\n";
	    }
	}
    }
}

close(OUT);


open(OUT,">../temp/whvfrp.txt");
print OUT "City Abbrev\tCurrent Year\tCurrent Month\tYear\tMonth\tVendor Fiscal Month\tVFRP Raw\tVFRP\tFiscal Month Count\tMo1\tMo2\tMo3\tMo4\tMo5\tMo6\tMo7\tMo8\tMo9\tMo10\tMo11\tMo12\n";

foreach $whle (@whlist) {

    ($currentyear,$currentmonth)=split("-",$currentym{$whle});
    $currentmonth--;
    $currentmonth++;
    $currentyear=int($currentyear);
    if ($currentmonth<0.5) {
	$currentmonth+=12;
	$currentyear--;
    }
       
    $y=$currentyear;
    $m=$currentmonth;
    
    foreach $i (1,2,3,4,5,6,7,8,9,10,11,12) {
	$fm[$i]=$currentmonth-$i;
	$MO12[$i]=$monthnames[$i];
	$MO1[$i]=$monthnames[$i+1];
	$MO2[$i]=$monthnames[$i+2];
	$MO3[$i]=$monthnames[$i+3];
	$MO4[$i]=$monthnames[$i+4];
	$MO5[$i]=$monthnames[$i+5];
	$MO6[$i]=$monthnames[$i+6];
	$MO7[$i]=$monthnames[$i+7];
	$MO8[$i]=$monthnames[$i+8];
	$MO9[$i]=$monthnames[$i+9];
	$MO10[$i]=$monthnames[$i+10];
	$MO11[$i]=$monthnames[$i+11];
	if ($fm[$i]<0.5) {$fm[$i]+=12;}
	$fy[$i]=9999;
#    $fm[$i]++;
	if($fm[$i]==1) {$fy[$i]=10000;}
#    $fy[$i]=10000 if ($i+1 eq int($currentmonth) || ($i-11 eq int($currentmonth));
    }
    
    
    until ($y<$currentyear-3) {
	foreach $i (1,2,3,4,5,6,7,8,9,10,11,12) {
	    $line="$whle\t$currentyear\t";
	    if ($currentmonth<10) {
		$line.="0"; 
	    }
	    $line.="$currentmonth\t$y\t";
	    $line.="0" if ($m<10);
	    $line.="$m\t$i\t$y-";
	    if($m<10) {$line.="0";}
	    $line.="$m-$i\t";
	    if ($currentmonth eq $m && $currentyear eq $y) {
		$fmcount[$i]=$fm[$i]-1;
		$fmcount[$i]=12 if $fmcount[$i]==0;
		$line.="0001-01\t$fmcount[$i]\t";
	    } else {
		$line.="$fy[$i]-";
		if($fm[$i]<10) {$line.="0";}
		$line.="$fm[$i]\t$fmcount[$i]\t";
	    }
	    $line.="$MO1[$i]\t";
	    $line.="$MO2[$i]\t";
	    $line.="$MO3[$i]\t";
	    $line.="$MO4[$i]\t";
	    $line.="$MO5[$i]\t";
	    $line.="$MO6[$i]\t";
	    $line.="$MO7[$i]\t";
	    $line.="$MO8[$i]\t";
	    $line.="$MO9[$i]\t";
	    $line.="$MO10[$i]\t";
	    $line.="$MO11[$i]\t";
	    $line.="$MO12[$i]\n";
#	print OUT "$y\t$m\t$i\t$fy[$i]\t$fm[$i]\n";
	    print OUT $line;
	    $fm[$i]--;
	    if($fm[$i]<0.5) {$fm[$i]=12; $fy[$i]--;}
	}
	$m--;
	if ($m<0.5) {$m=12;$y--;}
    }
}
