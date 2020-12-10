use Terminal::ANSIColor;


enum Animals(
    RABBIT => 1,
    SHEEP  => 6,
    PIG  => 6*2,
    COW    => 6*2*3,
    HORSE  => 6*2*3*2,
    WOLF   => -2,
    FOX    => -1,
    
    SMALL_DOG => 6,
    BIG_DOG   => 6*2*3
);

class OrangeDice {

    method roll {
        my $val = roll12;
        if $val < 5 {
            return RABBIT
        }
        elsif $val < 8 {
            return SHEEP        
        }
        elsif $val < 10 {
            return PIG
        }
        elsif $val < 11 {
            return HORSE
        }
        else {
            return FOX
        }
    }
}

class BlueDice {
    method roll {
        my $val = roll12;
        if $val < 6 {
            return RABBIT
        }
        elsif $val < 9 {
            return SHEEP        
        }
        elsif $val < 10 {
            return PIG
        }
        elsif $val < 11 {
            return COW
        }
        else {
            return WOLF
        }
    }
}

role Player {
    has Int %.animals;

    submethod BUILD {
        %!animals<SMALL_DOG> = 0;
        %!animals<BIG_DOG> = 0;

        %!animals<RABBIT> = 0;
        %!animals<SHEEP>  = 0;
        %!animals<PIG>    = 0;
        %!animals<COW>    = 0;
        %!animals<HORSE>  = 0;
    }
        
    method trade(Int %animals){}
 

    method gist {
        return  self ~ colored("DOG", "bold") ~ ":" ~ colored(%!animals<SMALL_DOG>.Str, "yellow") ~ "("
        ~ colored(%!animals<BIG_DOG>.Str, "red") ~ ") | "
        ~ colored("RABBIT", "bold")  ~ ":" ~ %!animals<RABBIT>  ~ " "
        ~ colored("SHEEP", "bold")   ~ ":" ~ %!animals<SHEEP>   ~ " "
        ~ colored("PIG", "bold")     ~ ":" ~ %!animals<PIG>     ~ " "
        ~ colored("COW", "bold")      ~ ":" ~ %!animals<COW>     ~ " "
        ~ colored("HORSE", "bold")   ~ ":" ~ %!animals<HORSE>;
  }
    
    method reproduce(OrangeDice $od, BlueDice $bd, Int %herd){
        my $bluesym = $bd.roll;
        my $orangesym = $od.roll;


#todo herd update!
        if $orangesym == $bluesym {
            #say "Double..." ~ $orangesym;
            my $offspring = ((%!animals{$orangesym} + 2) / 2).Int;
            %!animals{$orangesym} += $offspring;
        } else {
            #say "Orange... " ~ $orangesym ~ " Blue... " ~ $bluesym;
            if $bluesym != WOLF {
                my $offspringblue = ((%!animals{$bluesym} + 1) / 2).Int;
                %!animals{$bluesym} += $offspringblue;
            }

            if $orangesym != FOX {
                my $offspringorange = ((%!animals{$orangesym} + 1) / 2).Int;
                %!animals{$orangesym} += $offspringorange;
            }
        }
        
        if $bluesym == WOLF {
            
            print "Wolf came...";
            if %!animals<BIG_DOG> < 1 {
                %!animals<RABBIT> = 0;
                %!animals<SHEEP>  = 0;
                %!animals<PIG>    = 0;
                %!animals<COW>    = 0;
                say "many animals lost";
            } else {
                %!animals<BIG_DOG>--;
                say "big dog lost";
            }
        }

        if $orangesym == FOX {           
            print "Fox came...";
            if %!animals<SMALL_DOG> < 1 {
                %!animals<RABBIT> = 0;
                say "all rabbits lost";
            } else {
                %!animals<SMALL_DOG>--;
                say "small dog lost";
            }
        }
    }

    method hasWon {
        say self;
        %!animals<HORSE>     > 0
        && %!animals<RABBIT> > 0
        && %!animals<SHEEP>  > 0
        && %!animals<PIG>    > 0
        && %!animals<COW>    > 0;
    }
}

=begin pod

=head1 ModelDumpProtectiveStrategy

Simplest of them all

=item Buys dogs at priority
=item Buys biggest animal can afford.
=item Only trades lower level animal.

=end pod
class DumbProtectivePlayer does Player {
    
    method trade(Int %lv){
        
        if %!animals<SMALL_DOG> < 1 && %!animals<SHEEP> > 0 {
            say "Buying small dog";
            %!animals<SMALL_DOG> += 1;
            %!animals<SHEEP>     -= 1;
        } elsif %!animals<BIG_DOG> < 1 && %!animals<COW> > 0 {
            say "Buying big dog";
            %!animals<BIG_DOG> += 1;
            %!animals<COW> -=  1;
        } elsif %!animals<HORSE> < 1 && %!animals<COW> > 1 {
            say "Buying horse";
            %!animals<COW>   -= 2;
            %!animals<HORSE> += 1;
        } elsif %!animals<PIG> > 2 {
            say "Buying cow";
            %!animals<PIG> -= 3;
            %!animals<COW> += 1;
        } elsif %!animals<SHEEP> > 1 {
            say "Buying pig";
            %!animals<SHEEP> -= 2;
            %!animals<PIG>   += 1;
        } elsif %!animals<RABBIT> > 5 {
            say "Buying sheep";
            %!animals<RABBIT> -= 6;
            %!animals<SHEEP>  += 1;
        }
    }
}


=begin pod

Buy as fast as possible

=end pod
class EagerProtectivePlayer does Player {
    
    method trade(Int %lv){
        print self;
        if %!animals<SMALL_DOG> < 1 && %!animals<SHEEP> > 0 {
            say "Buying small dog";
            %!animals<SMALL_DOG> += 1;
            %!animals<SHEEP>     -= 1;
        } elsif %!animals<BIG_DOG> < 1 && %!animals<COW> > 0 {
            say "Buying big dog";
            %!animals<BIG_DOG> += 1;
            %!animals<COW> -=  1;
        } elsif %!animals<RABBIT> > 6 {
            say "Buying sheep";
            %!animals<RABBIT> -= 6;
            %!animals<SHEEP>  += 1;
        } elsif %!animals<SHEEP> > 2 {
            say "Buying pig";
            %!animals<SHEEP> -= 2;
            %!animals<PIG>   += 1;
        } elsif %!animals<PIG> > 3 {
            say "Buying cow";
            %!animals<PIG> -= 3;
            %!animals<COW> += 1;
        } elsif %!animals<HORSE> < 1 && %!animals<COW> > 2 {
            say "Buying horse";
            %!animals<COW>   -= 2;
            %!animals<HORSE> += 1;
        }
    }
}
class Trade{
    has Animals $.what;
    has Animals %.stock;

    method buy(Animals $a){
        $!what = $a;
        return self;
    }

    method with(Animals %stock){
        %!stock = %stock;
        return self;
    }

    method by(Animals %ls){
        if %ls{$!what} > 0 {
            given $!what {
                when SHEEP {
                    %!stock{SHEEP} += 1;
                    %!stock{RABBIT} -= 6;
                    
                    %ls{SHEEP} -=1;
                    %ls{RABBIT} += 6;
                }
                default {die;}
            }
        }
    }

}

sub roll12 {
    return rand * 12;
}

class SuperFarmer {
    has Player @.players;   
    has OrangeDice $.orangedice= OrangeDice.new;
    has BlueDice $.bluedice = BlueDice.new;

    has Int %.animal_bank;

    submethod BUILD {
        %!animal_bank<RABBIT> = 60;
        %!animal_bank<SHEEP>  = 24;
        %!animal_bank<PIG>  = 20;
        %!animal_bank<HORSE>  = 6;

        %!animal_bank<SMALL_DOG> = 4;
        %!animal_bank<BIG_DOG>   = 2;
        
        say "Initializing herd";
    }    

    method play-until-winner {
        @.players.push(DumbProtectivePlayer.new);
        @.players.push(EagerProtectivePlayer.new);
        for 1..100 -> $i {
            for @.players -> $player {
                $player.trade(%!animal_bank);
                $player.reproduce($.orangedice, $.bluedice, %!animal_bank);

                return "Game ended at " ~ $i ~ "turn by player " ~ $player if $player.hasWon;
            }
        }

        die "Turn limit exceeded";
    }
}




#say BlueDice.new().roll;
#say OrangeDice.new().roll;
say SuperFarmer.new().play-until-winner;
