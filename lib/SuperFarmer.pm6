use Terminal::ANSIColor;

=begin pod

=head1 SUPERFARMER

=head2 Game consists

=item1 animal bank
=table
 RABBITs            60
 SHEEPs             24
 PIGs               20
 HORSEs              6
 SMALL_DOGs          4
 BIG_DOGs            2

 
=item1 orange dice
=table
RABBIT               5 sides
SHEEP                3 sides 
PIG                  2 sides
HORSE                1 side
FOX                  1 side

=item1 blue dice
=table
RABBIT               6 sides
SHEEP                3 sides 
PIG                  1 sides
COW                  1 side
WOLF                 1 side

=item1 player's board

=head2 Turn

Player wins if has at least one  RABBIT, SHEEP, PIG, COW and HORSE

=head3 Trading

Trade can be done with animal bank or other player.
Trading options

=item Many to one 

=item One to many

Any combinations are allowed. Animals values:

=table
SHEEP          5 RABBITs
PIG            2 SHEEPs
COW            3 PIGs
HORSE          2 COWs
SMALL_DOG      1 SHEEP
BIG_DOG        1 COW

=head3 Offspring generation and losing animals

Offspring can be generated directly from dices if same symbol is rolled on both.
New animals are also generated if one symbol is roled but player owns at least one animal.
Every pair of animal gives one animal including ones on dice

=head4 FOX

If SMALL_DOG is owned it is removed. Otherwise all RABBITs go back to bank

=head4 WOLF

If big dog is owned it is removed. Otherwise all animals except SMALL_DOGs and HORSEs go back to bank

=end pod

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

sub create_empty_animals{
    my Int %animals;
    %animals<SMALL_DOG> = 0;
    %animals<BIG_DOG> = 0;

    %animals<RABBIT> = 0;
    %animals<SHEEP>  = 0;
    %animals<PIG>    = 0;
    %animals<COW>    = 0;
    %animals<HORSE>  = 0;
    
    return %animals;
}

role Player {
    has Int %.player_animals;

    submethod BUILD {
        %!player_animals = create_empty_animals;    
    }
        
    method trade(Int %animal_bank){}
 
    
    method gist {
        return  self.player-name ~ colored("DOG", "bold") ~ ":" ~ colored(%!player_animals<SMALL_DOG>.Str, "yellow") ~ "/"
        ~ colored(%!player_animals<BIG_DOG>.Str, "red") ~ " | "
        ~ colored("RABBIT", "bold")  ~ ":" ~ %!player_animals<RABBIT>  ~ " "
        ~ colored("SHEEP", "bold")   ~ ":" ~ %!player_animals<SHEEP>   ~ " "
        ~ colored("PIG", "bold")     ~ ":" ~ %!player_animals<PIG>     ~ " "
        ~ colored("COW", "bold")      ~ ":" ~ %!player_animals<COW>     ~ " "
        ~ colored("HORSE", "bold")   ~ ":" ~ %!player_animals<HORSE>;
    }

    method limit_available(%animal_bank, $offsping, Animals $animal){
        my Int $limited =  min(%animal_bank{$animal}, $offsping);
        %animal_bank{$animal} -= $limited;
        return $limited;
    }


    
    method reproduce(OrangeDice $od, BlueDice $bd, Int %animal_bank){
        my $bluesym = $bd.roll;
        my $orangesym = $od.roll;


#todo herd update!
        if $orangesym == $bluesym {
            #say "Double..." ~ $orangesym;
            my $offspring = ((%!player_animals{$orangesym} + 2) / 2).Int;
            %!player_animals{$orangesym} += self.limit_available(%animal_bank, $offspring, $bluesym);
        } else {
            #say "Orange... " ~ $orangesym ~ " Blue... " ~ $bluesym;
            if $bluesym != WOLF {
                my $offspringblue = ((%!player_animals{$bluesym} + 1) / 2).Int;
                %!player_animals{$bluesym} += self.limit_available(%animal_bank, $offspringblue, $bluesym);
            }

            if $orangesym != FOX {
                my $offspringorange = ((%!player_animals{$orangesym} + 1) / 2).Int;
                %!player_animals{$orangesym} += self.limit_available(%animal_bank, $offspringorange, $orangesym);
            }
        }
        
        if $bluesym == WOLF {
            
            print "Wolf came...";
            if %!player_animals<BIG_DOG> < 1 {
                %animal_bank<RABBIT> += %!player_animals<RABBIT>;
                %!player_animals<RABBIT> = 0;
                
                %animal_bank<SHEEP> += %!player_animals<SHEEP>;
                %!player_animals<SHEEP>  = 0;
                
                %animal_bank<PIG> += %!player_animals<PIG>;
                %!player_animals<PIG>    = 0;
                
                %animal_bank<COW> += %!player_animals<COW>;
                %!player_animals<COW>    = 0;
                
                say "many player_animals lost";
            } else {
                %!player_animals<BIG_DOG>--;
                %animal_bank<BIG_DOG>++;

                say "big dog lost";
            }
        }

        if $orangesym == FOX {           
            print "Fox came...";
            if %!player_animals<SMALL_DOG> < 1 {
                
                %animal_bank<RABBIT> += %!player_animals<RABBIT>;
                %!player_animals<RABBIT> = 0;
                
                say "all rabbits lost";
            } else {
                %!player_animals<SMALL_DOG>--;
                %animal_bank<SMALL_DOG>++;
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

#| Simplest of them all
#| * buys dogs at priority
#| * buys biggest animal can afford.
#| * only trades lower level animal.
class DumbProtectivePlayer does Player {


    method player-name {

        return colored("DumbProtect ", "green");
        
    }
    
    method trade(Int %animal_bank){
        my %transaction = create_empty_animals;
        if %!player_animals<SMALL_DOG> < 1 && %!player_animals<SHEEP> > 0 {
            say "Buying small dog";
            %transaction<SMALL_DOG> += 1;
            %transaction<SHEEP>     -= 1;
        } elsif %!player_animals<BIG_DOG> < 1 && %!player_animals<COW> > 0 {
            say "Buying big dog";
            %transaction<BIG_DOG> += 1;
            %transaction<COW> -=  1;
        } elsif %!player_animals<HORSE> < 1 && %!player_animals<COW> > 1 {
            say "Buying horse";
            %transaction<COW>   -= 2;
            %transaction<HORSE> += 1;
        } elsif %!player_animals<PIG> > 2 {
            say "Buying cow";
            %transaction<PIG> -= 3;
            %transaction<COW> += 1;
        } elsif %!player_animals<SHEEP> > 1 {
            say "Buying pig";
            %transaction<SHEEP> -= 2;
            %transaction<PIG>   += 1;
        } elsif %!player_animals<RABBIT> > 5 {
            say "Buying sheep";
            %transaction<RABBIT> -= 6;
            %transaction<SHEEP>  += 1;
        }

          for  %transaction.keys -> $key {
            %!player_animals{$key} += %transaction{$key};
            %animal_bank{$key} -= %transaction{$key};
        }
    }
}


#| Buy as fast as possible
class EagerProtectivePlayer does Player {
    
    method player-name {        
        return colored("EagerProtect ", "yellow");        
    } 
    method trade(Int %animal_bank){
        my Int %transaction = create_empty_animals;
        if %!player_animals<SMALL_DOG> < 1 && %!player_animals<SHEEP> > 0 {
            say "Buying small dog";
            %transaction<SMALL_DOG> += 1;
            %transaction<SHEEP> -= 1;
        } elsif %!player_animals<BIG_DOG> < 1 && %!player_animals<COW> > 0 {
            say "Buying big dog";
            %transaction<BIG_DOG> += 1;
            %transaction<COW> -=  1;
        } elsif %!player_animals<RABBIT> > 6 {
            say "Buying sheep";
            %transaction<RABBIT> -= 6;
            %transaction<SHEEP>  += 1;
        } elsif %!player_animals<SHEEP> > 2 {
            say "Buying pig";
            %transaction<SHEEP> -= 2;
            %transaction<PIG>   += 1;
        } elsif %!player_animals<PIG> > 3 {
            say "Buying cow";
            %transaction<PIG> -= 3;
            %transaction<COW> += 1;
        } elsif %!player_animals<HORSE> < 1 && %!player_animals<COW> > 2 {
            say "Buying horse";
            %transaction<COW>   -= 2;
            %transaction<HORSE> += 1;
        }

        for  %transaction.keys -> $key {
            %!player_animals{$key} += %transaction{$key};
            %animal_bank{$key} -= %transaction{$key};
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
        for 1..1000 -> $i {
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
