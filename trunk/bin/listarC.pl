#!/usr/bin/perl -w
# 
# 
#
# Autor: Carlos Pantelides 74901
#
#
use strict;
use warnings;

# adaptado de http://www.perlmonks.org/index.pl?node_id=162876
my $libpath; 
BEGIN {
  $libpath = $ENV{GRUPO} . "/lib";
}
use lib $libpath;


use lib $libpath || die("no libpath");;
use Util;
use Lib;


# Los datos que hacen falta de la configuracion son:
#	~/grupo2/mae
#	~/grupo2/ya/encuestas.sum
#	~/grupo2/ya/
#	~/grupo2/lib/ 

my $grupo=$ENV{GRUPO};
my $suma_encuestas="$grupo/ya/encuestas.sum";
my $maestro_encuestadores="$grupo/mae/encuestadores.mae";
my $maestro_encuestas="$grupo/mae/encuestas.mae";
my $maestro_preguntas="$grupo/mae/preguntas.mae";



my $salida_pantalla = 0;
my $salida_archivo  = 0;

my @encuestadores;
my @codigos;
my @numeros;
my @sitios;
my @agrupacion;


# Refactorizacion 1
# Llevar este codigo a Lib.pm
# Debe devolver los arrays, salida, estado error/ayuda

# Refactorizacion 2
# Mover a una funcion el codigo duplicado de -E -S -M -C -A

my $indice		  = 0;

my $ayuda		   = 0;
my $error		   = "";


# if ($#ARGV == -1 ) {
#	 $error .= "Debe proveer algún argumento\n";
# }


# 0: indice
# 1: error
sub procesar($$$$) {
	my @lista  = $_[0];
	my @argv   = $_[1];
	my $indice = $_[2];
	my $error  = $_[3];

	#my $rlista = \@lista;
	#my $rargv  = \@argv;

	my $fin_items= 0;
	while ($$indice < $#ARGV && ! $fin_items) {                  # corregir
		print "indice: $$indice\n";                          # eliminar
		$$indice++;
		if ( $ARGV[$$indice] =~ /^-.*/ ) {                   # corregir
			$$indice--;
			$fin_items = 1;
			print "proximo\n";                           # eliminar
		} else {
			print "push\n";                               # eliminar
			push(@encuestadores, ($ARGV[$$indice]));      # corregir
		}
	}
	if ( $#encuestadores == -1) {                                  # corregir
		$$error .= "Debe proveer algun elemento para -E\n";
	}

}


while ($indice < $#ARGV + 1  && ! $ayuda && ! $error) {
	my $elem = $ARGV[$indice];
	if ($elem =~ /-h/) {
		# Menu de ayuda
		$ayuda = 1;
	} elsif ($elem eq '-c' ) {
		# Consulta a pantalla

		$salida_pantalla = 1;
	} elsif ($elem eq '-e' ) {
		# Consulta a archivo
		$salida_archivo = 1;
	} elsif ($elem eq '-E' ) {
		# Encuestador

#		procesar(\@encuestadores, @ARGV, \$indice, \$error);

		 my $fin_items= 0;
		 while ($indice < $#ARGV && ! $fin_items) {
			 $indice++;
			 if ( $ARGV[$indice] =~ /^-.*/ ) {
				 $indice--;
				 $fin_items = 1;
			 } else {
				 push(@encuestadores, ($ARGV[$indice])); 
			 }
		 }
		 if ( $#encuestadores == -1) {
			$error .= "Debe proveer algun elemento para -E\n";
		 }
	} elsif ($elem eq '-C' ) {
		# Codigo encuesta
		my $fin_items= 0;
		while ($indice < $#ARGV && ! $fin_items) {
			$indice++;
			if ( $ARGV[$indice] =~ /^-.*/ ) {
				$indice--;
				$fin_items = 1;
			} else {
				push(@codigos, ($ARGV[$indice])); 
			}
		}
		if ( $#codigos == -1 ) {
		   $error .= "Debe proveer algun elemento para -C\n";
		}
	} elsif ($elem eq '-N') {
		# Numero de encuesta
		my $fin_items= 0;
		while ($indice < $#ARGV && ! $fin_items) {
			$indice++;
			if ( $ARGV[$indice] =~ /^-.*/ ) {
				$indice--;
				$fin_items = 1;
			} else {
				push(@numeros, ($ARGV[$indice])); 
			}
		}
		if ( $#numeros == -1 ) {
		   $error .= "Debe proveer algun elemento para -N\n";
		}
	} elsif ($elem eq '-S') {
		# Sitio de encuesta
		my $fin_items= 0;
		while ($indice < $#ARGV && ! $fin_items) {
			$indice++;
			if ( $ARGV[$indice] =~ /^-.*/ ) {
				$indice--;
				$fin_items = 1;
			} else {
				push(@sitios, ($ARGV[$indice])); 
			}
		}
		if ( $#sitios == -1 ) {
		   $error .= "Debe proveer algun elemento para -S\n";
		}

	} elsif ($elem eq '-A') {
		# Agrupacion
		my $fin_items= 0;
		while ($indice < $#ARGV && ! $fin_items) {
			$indice++;
			if ( $ARGV[$indice] =~ /^-.*/ ) {
				$indice--;
				$fin_items = 1;
			} else {
				push(@agrupacion, ($ARGV[$indice])); 
			}
		}
		if ( $#agrupacion == -1 ) {
		   $error .= "Debe proveer algun elemento para -A\n";
		}
	} else {
		$error .= "Argumento desconocido $elem\n";
	}
	$indice++;
}

if ( $#encuestadores == -1 && $#codigos == -1 && $#numeros == -1 && $#sitios == -1) {
   $error .= "Debe proveer algún criterio -E -C -N -S\n";
}

if ( $salida_pantalla == 0 && $salida_archivo == 0) {
	$error .= "Debe proveer un destino -c o -e\n";
}

if ($error) {
	print "Error: $error\n";
}

if ($error || $ayuda) {
	print "Mensaje de ayuda\n";
} else {
	if ($salida_pantalla) {
		print "Salida a pantalla seleccionada\n";
	} 
	if ($salida_archivo) {
	   print "Salida a archivo seleccionada\n";
	}
     if (1) {
	Util::imprimir_argumentos('Encuestadores', @encuestadores);
	Util::imprimir_argumentos('Códigos', @codigos);
	Util::imprimir_argumentos('Números', @numeros);
	Util::imprimir_argumentos('Sitios', @sitios);
	Util::imprimir_argumentos('Agrupacion', @agrupacion);
    }
}

# fin Refactorizacion 2


# fin Refactorizacion 1

my %encuestas = Lib::cargar_encuestas($maestro_encuestas);
my %encuestadores = Lib::cargar_encuestadores($maestro_encuestadores);
my %preguntas = Lib::cargar_preguntas($maestro_preguntas);

if (1) {
Util::imprimir_maestro(\%encuestas);
Util::imprimir_maestro(\%encuestadores);
Util::imprimir_maestro(\%preguntas);

#my %suma = Lib::cargar_suma($suma_encuestas);
#Util::imprimir_lista(\%suma);
}



# encuestador= *				 -E
# codigo_encuesta= *			 -C 
# numero_encuesta=1, rango, *	-N
# sitio_encuensta= *			 -S
# 
# -c 
# -e
# -h
# 
# outdir=ya
# reportname=fecha:hora.txt
