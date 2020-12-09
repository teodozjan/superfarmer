enum Animals(
    RABBIT => 1,
    SHEEP  => 6,
    SWINE  => 6*2,
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
    %animals<SWINE>  = 20;
    %animals<HORSE>  = 6;

    %animals<SMALL_DOG> = 4;
    %animals<BIG_DOG>   = 2;
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
            return SWINE
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
            return SWINE
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
    has TradeStrategy @tradeStrategy;  
    
    method trade(LiveStock){}
    method reproduce(OrangeDice, BlueDice, LiveStock){}
}


sub roll12 {
    return rand * 12;
}

class SuperFarmer {
    has Player @.players;
    has LiveStock $.livestock = LiveStock.new;
    has OrangeDice $.orangedice= OrangeDice.new;
    has BlueDice $.bluedice = BlueDice.new;
}

say BlueDice.new().roll;
say OrangeDice.new().roll;
say SuperFarmer.new;
