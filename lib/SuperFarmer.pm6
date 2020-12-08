enum Animals(
    RABBIT => 1,
    SHEEP => 6,
    SWINE => 6*2,
    COW => 6*2*3,
    HORSE => 6*2*3*2,
    WOLF => -2,
    FOX => -1
);

class Player{}

class LiveStock{}

sub roll12 {
    return rand * 12;
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

class SuperFarmer {
    has Player @.players;
    has LiveStock $.livestock = LiveStock.new;
    has OrangeDice $.orangedice= OrangeDice.new;
    has BlueDice $.bluedice = BlueDice.new;
}

say BlueDice.new().roll.value;
