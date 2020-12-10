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
    has Int %.player_animals;

    submethod BUILD {
        %!player_animals<SMALL_DOG> = 0;
        %!player_animals<BIG_DOG> = 0;

        %!player_animals<RABBIT> = 0;
        %!player_animals<SHEEP>  = 0;
        %!player_animals<PIG>    = 0;
        %!player_animals<COW>    = 0;
        %!player_animals<HORSE>  = 0;
    }
        
    method trade(Int %animal_bank){}
 

    method gist {
        return  self ~ colored("DOG", "bold") ~ ":" ~ colored(%!player_animals<SMALL_DOG>.Str, "yellow") ~ "("
        ~ colored(%!player_animals<BIG_DOG>.Str, "red") ~ ") | "
        ~ colored("RABBIT", "bold")  ~ ":" ~ %!player_animals<RABBIT>  ~ " "
        ~ colored("SHEEP", "bold")   ~ ":" ~ %!player_animals<SHEEP>   ~ " "
        ~ colored("PIG", "bold")     ~ ":" ~ %!player_animals<PIG>     ~ " "
        ~ colored("COW", "bold")      ~ ":" ~ %!player_animals<COW>     ~ " "
        ~ colored("HORSE", "bold")   ~ ":" ~ %!player_animals<HORSE>;
  }
    
    method reproduce(OrangeDice $od, BlueDice $bd, Int %herd){
        my $bluesym = $bd.roll;
        my $orangesym = $od.roll;


#todo herd update!
        if $orangesym == $bluesym {
            #say "Double..." ~ $orangesym;
            my $offspring = ((%!player_animals{$orangesym} + 2) / 2).Int;
            %!player_animals{$orangesym} += $offspring;
        } else {
            #say "Orange... " ~ $orangesym ~ " Blue... " ~ $bluesym;
            if $bluesym != WOLF {
                my $offspringblue = ((%!player_animals{$bluesym} + 1) / 2).Int;
                %!player_animals{$bluesym} += $offspringblue;
            }

            if $orangesym != FOX {
                my $offspringorange = ((%!player_animals{$orangesym} + 1) / 2).Int;
                %!player_animals{$orangesym} += $offspringorange;
            }
        }
        
        if $bluesym == WOLF {
            
            print "Wolf came...";
            if %!player_animals<BIG_DOG> < 1 {
                %!player_animals<RABBIT> = 0;
                %!player_animals<SHEEP>  = 0;
                %!player_animals<PIG>    = 0;
                %!player_animals<COW>    = 0;
                say "many player_animals lost";
            } else {
                %!player_animals<BIG_DOG>--;
                say "big dog lost";
            }
        }

        if $orangesym == FOX {           
            print "Fox came...";
            if %!player_animals<SMALL_DOG> < 1 {
                %!player_animals<RABBIT> = 0;
                say "all rabbits lost";
            } else {
                %!player_animals<SMALL_DOG>--;
                say "small dog lost";
            }
        }
    }

    method hasWon {
        say self;
        %!player_animals<HORSE>     > 0
        && %!player_animals<RABBIT> > 0
        && %!player_animals<SHEEP>  > 0
        && %!player_animals<PIG>    > 0
        && %!player_animals<COW>    > 0;
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
    
    method trade(Int %animal_bank){
        
        if %!player_animals<SMALL_DOG> < 1 && %!player_animals<SHEEP> > 0 {
            say "Buying small dog";
            %!player_animals<SMALL_DOG> += 1;
            %!player_animals<SHEEP>     -= 1;
        } elsif %!player_animals<BIG_DOG> < 1 && %!player_animals<COW> > 0 {
            say "Buying big dog";
            %!player_animals<BIG_DOG> += 1;
            %!player_animals<COW> -=  1;
        } elsif %!player_animals<HORSE> < 1 && %!player_animals<COW> > 1 {
            say "Buying horse";
            %!player_animals<COW>   -= 2;
            %!player_animals<HORSE> += 1;
        } elsif %!player_animals<PIG> > 2 {
            say "Buying cow";
            %!player_animals<PIG> -= 3;
            %!player_animals<COW> += 1;
        } elsif %!player_animals<SHEEP> > 1 {
            say "Buying pig";
            %!player_animals<SHEEP> -= 2;
            %!player_animals<PIG>   += 1;
        } elsif %!player_animals<RABBIT> > 5 {
            say "Buying sheep";
            %!player_animals<RABBIT> -= 6;
            %!player_animals<SHEEP>  += 1;
        }
    }
}


=begin pod

Buy as fast as possible

=end pod
class EagerProtectivePlayer does Player {
    
    method trade(Int %animal_bank){
        print self;
        if %!player_animals<SMALL_DOG> < 1 && %!player_animals<SHEEP> > 0 {
            say "Buying small dog";
            %!player_animals<SMALL_DOG> += 1;
            %!player_animals<SHEEP>     -= 1;
        } elsif %!player_animals<BIG_DOG> < 1 && %!player_animals<COW> > 0 {
            say "Buying big dog";
            %!player_animals<BIG_DOG> += 1;
            %!player_animals<COW> -=  1;
        } elsif %!player_animals<RABBIT> > 6 {
            say "Buying sheep";
            %!player_animals<RABBIT> -= 6;
            %!player_animals<SHEEP>  += 1;
        } elsif %!player_animals<SHEEP> > 2 {
            say "Buying pig";
            %!player_animals<SHEEP> -= 2;
            %!player_animals<PIG>   += 1;
        } elsif %!player_animals<PIG> > 3 {
            say "Buying cow";
            %!player_animals<PIG> -= 3;
            %!player_animals<COW> += 1;
        } elsif %!player_animals<HORSE> < 1 && %!player_animals<COW> > 2 {
            say "Buying horse";
            %!player_animals<COW>   -= 2;
            %!player_animals<HORSE> += 1;
        }
    }
}
class Trade{
    has Animals $.animal_to_buy;
    has Animals %.player_animals;

    method buy(Animals $a){
        $!animal_to_buy = $a;
        return self;
    }

    method with(Animals %player_animals){
        %!player_animals = %player_animals;
        return self;
    }

    method by(Animals %animal_bank){
        if %animal_bank{$!animal_to_buy} > 0 {
            given $!animal_to_buy {
                when SHEEP {
                    %!player_animals{SHEEP} += 1;
                    %!player_animals{RABBIT} -= 6;
                    
                    %animal_bank{SHEEP} -=1;
                    %animal_bank{RABBIT} += 6;
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
    has OrangeDice $.orangedice = OrangeDice.new;
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
