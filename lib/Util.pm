#!/usr/bin/perl -w

use strict;
use warnings;

package Util;

our @EXPORT = qw(
    hash_walk
    print_keys_and_value
    imprimir_maestro
    imprimir_argumentos
);

sub hash_walk {
    my ($hash, $key_list, $callback) = @_;
    while (my ($k, $v) = each %$hash) {
        # Keep track of the hierarchy of keys, in case
        # our callback needs it.
        push @$key_list, $k;

        if (ref($v) eq 'HASH') {
            # Recurse.
            hash_walk($v, $key_list, $callback);
        }
        else {
            # Otherwise, invoke our callback, passing it
            # the current key and value, along with the
            # full parentage of that key.
            $callback->($k, $v, $key_list);
        }

        pop @$key_list;
    }
}

sub print_keys_and_value {
    my ($k, $v, $key_list) = @_;
    printf "k = %-8s  v = %-4s  key_list = [%s]\n", $k, $v, "@$key_list";
}

sub imprimir_argumentos {
    my ($nombre, @lista) = @_;
    if ($#lista != -1) {
        print "$nombre\n";
        foreach my $item (@lista) {
            print "    $item\n";
        }
    }
}

sub imprimir_maestro {
    my($lista) = @_;
    while (my ($k1,$v1) = each %$lista) {
        while (my ($k2, $v2) = each %$v1) {
          print "$k1 $k2 = $v2\n";
        }
    }

}

1;