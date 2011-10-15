#!/usr/bin/perl -w
# 
# Funciones auxiliares
#
# Autor: Carlos Pantelides 74901
#
#
use strict;
use warnings;

package Util;

our @EXPORT = qw(
	hash_walk
	print_keys_and_value
	imprimir_maestro
	imprimir_argumentos
);
sub hash_walk($$$);

# Uso:
# hash_walk(\%data, [], \&print_keys_and_value);
sub hash_walk($$$) {
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

sub print_keys_and_value() {
	my ($k, $v, $key_list) = @_;
	printf STDERR "k = %-8s  v = %-4s  key_list = [%s]\n", $k, $v, "@$key_list";
}

sub imprimir_criterios($@) {
	my ($nombre, @lista) = @_;
	if ($#lista != -1) {
		print STDERR "$nombre\n";
		foreach my $item (@lista) {
			print STDERR "	$item\n";
		}
	}
}

sub imprimir_hash(%) {
	my (%lista) = @_;
	my $clave;
	my $valor;
	while (($clave,$valor) = each(%lista)) {
		print STDERR "$clave => $valor \n";
	}
}


sub imprimir_maestro(@) {
	my($lista) = @_;
	while (my ($k1,$v1) = each %$lista) {
		while (my ($k2, $v2) = each %$v1) {
		  print STDERR "$k1 $k2 = $v2\n";
		}
	}

}

sub dieWithCode($$) {
	print STDERR $_[0];
	exit $_[1];
}
1;