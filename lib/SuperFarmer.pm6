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

class LiveStock {
    
    has Int %animals;

    submethod BUILD {
        %animals<RABBIT> = 60;
        %animals<SHEEP>  = 24;
        %animals<PIG>  = 20;
        %animals<HORSE>  = 6;

        %animals<SMALL_DOG> = 4;
        %animals<BIG_DOG>   = 2;
        
        say %animals;
    }    
}

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

role TradeStrategy { }


class Player {
    has Int %animals;
    has TradeStrategy $tradeStrategy;  
    
    method trade(LiveStock){}
    method reproduce(OrangeDice $od, BlueDice $bd, LiveStock $herd){
        my $bluesym = $od.roll;
        my $orangesym = $bd.roll;


#todo herd update!
        if $orangesym == $bluesym {
            say "Double..." ~ $orangesym;
            my $offspring = (%animals{$orangesym} + 2) / 2;
            %animals{$orangesym} += $offspring;
        } else {
            say "Orange... " ~ $orangesym;
            say "Blue..." ~ $bluesym;

            my $offspringblue = (%animals{$bluesym} + 1) / 2;
            %animals{$bluesym} += $offspringblue;

            my $offspringorange = (%animals{$orangesym} + 1) / 2;
            %animals{$orangesym} += $offspringorange;
        }
        
        if $bluesym == WOLF {
            print "Wolf came...";
            if %animals<BIG_DOG> < 1 {
                %animals<RABBIT> = 0;
                %animals<SHEEP>  = 0;
                %animals<PIG>    = 0;
                %animals<COW>    = 0;
                say "animals lost";
            } else {
                %animals<BIG_DOG>--;
                say "big dog lost";
            }
        }

        if $orangesym == FOX {
            print "Fox came...";
            if %animals<BIG_DOG> < 1 {
                %animals<RABBIT> = 0;
                say "animals lost";
            } else {
                %animals<SMALL_DOG>--;
                say "small dog lost";
            }
        }
    }

    method hasWon {
        %animals<HORSE>     > 0
        && %animals<RABBIT> > 0
        && %animals<SHEEP>  > 0
        && %animals<PIG>    > 0
        && %animals<COW>    > 0;
    }
}


sub roll12 {
    return rand * 12;
}

class SuperFarmer {
    has Player @.players;
    has LiveStock $.livestock = LiveStock.new;
    has OrangeDice $.orangedice= OrangeDice.new;
    has BlueDice $.bluedice = BlueDice.new;

    method play-until-winner {
        for 1..100 {
            for @.players -> $player {
                $player.trade($.livestock);
                $player.reproduce($.orangedice, $.bluedice, $.livestock);
            }
        }

        die "Turn limit exceeded";
    }
}

#say BlueDice.new().roll;
#say OrangeDice.new().roll;
say SuperFarmer.new().play-until-winner;
