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
my $suma_encuestas=$ENV{ARCHIVO_ENCUESTAS};
my $directorio_reportes=$ENV{DIRECTORIO_YA};

my $maestro_encuestadores="$grupo/mae/encuestadores.mae";
my $maestro_encuestas="$grupo/mae/encuestas.mae";
my $maestro_preguntas="$grupo/mae/preguntas.mae";



my $salida_pantalla = 0;
my $salida_archivo  = 0;

my @criterio_encuestadores;
my @criterio_codigos;
my @criterio_numeros;
my @criterio_sitios;
my @criterio_agrupacion;


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
			push(@lista, ($ARGV[$$indice]));      # corregir
		}
	}
	if ( $#lista == -1) {                                  # corregir
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
				 push(@criterio_encuestadores, ($ARGV[$indice])); 
			 }
		 }
		 if ( $#criterio_encuestadores == -1) {
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
				push(@criterio_codigos, ($ARGV[$indice])); 
			}
		}
		if ( $#criterio_codigos == -1 ) {
		   $error .= "Debe proveer algun elemento para -C\n";
		}
	} elsif ($elem eq '-N') {
		# Numero de encuesta
		# @TODO: uno o dos numeros
		my $fin_items= 0;
		while ($indice < $#ARGV && ! $fin_items) {
			$indice++;
			if ( $ARGV[$indice] =~ /^-.*/ ) {
				$indice--;
				$fin_items = 1;
			} else {
				push(@criterio_numeros, ($ARGV[$indice])); 
			}
		}
		if ( $#criterio_numeros == -1 ) {
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
				push(@criterio_sitios, ($ARGV[$indice])); 
			}
		}
		if ( $#criterio_sitios == -1 ) {
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
				push(@criterio_agrupacion, ($ARGV[$indice])); 
			}
		}
		if ( $#criterio_agrupacion == -1 ) {
		   $error .= "Debe proveer algun elemento para -A\n";
		}
	} else {
		$error .= "Argumento desconocido $elem\n";
	}
	$indice++;
}

# if ( ! $ayuda 
# 	&& (
# 		$criterio_encuestadores == -1 
# 		&& $#criterio_codigos == -1 
# 		&& $#criterio_numeros == -1 
# 		&& $#criterio_sitios == -1) 
# 	) {
# 	$error .= "Debe proveer algún criterio -E -C -N -S\n";
# }
# 
if ( ! $ayuda && ( $salida_pantalla == 0 && $salida_archivo == 0) ) {
	$error .= "Debe proveer un destino -c o -e\n";
}

if ($error) {
	print "Error: $error\n";
}

if ($error || $ayuda) {
	print "Mensaje de ayuda\n";
}

if ($error) {
	exit 2;
}

if ($ayuda) {
	exit 1;
}

if ($salida_pantalla) {
	print "Salida a pantalla seleccionada\n";
} 
if ($salida_archivo) {
	print "Salida a archivo seleccionada\n";
}
if (1) {

Util::imprimir_criterios('Encuestadores', @criterio_encuestadores);
Util::imprimir_criterios('Códigos', @criterio_codigos);
Util::imprimir_criterios('Números', @criterio_numeros);
Util::imprimir_criterios('Sitios', @criterio_sitios);
Util::imprimir_criterios('Agrupacion', @criterio_agrupacion);

}


# fin Refactorizacion 2


# fin Refactorizacion 1

my %encuestas     = Lib::cargar_encuestas($maestro_encuestas);
my %encuestadores = Lib::cargar_encuestadores($maestro_encuestadores);
my %preguntas     = Lib::cargar_preguntas($maestro_preguntas);

if (0) {
Util::imprimir_maestro(\%encuestas);
Util::imprimir_maestro(\%encuestadores);
Util::imprimir_maestro(\%preguntas);
}


my %lista;
open(ARCHIVO,$suma_encuestas) || die ("No se pudo cargar $suma_encuestas: $!");
while (<ARCHIVO>) {
chomp;
	my %registro;
	my $fecha;
	my $cliente;
	my $modalidad;
	my $persona;
	( 
		$registro{"encuestador"},
		$fecha,
		$registro{"numero"},
		$registro{"codigo"},
		$registro{"puntaje"},
		$cliente,
		$registro{"sitio"},
		$modalidad,
		$persona
	) = split(/,/);

	#$lista{$registro{"encuestador"}}=\%registro;

# +Encuestador: key de %encuestadores
# |        +Fecha:NO INTERESA
# |        |        +Numero: unico local
# |        |        |    +Codigo encuesta: key de %encuestas
# |        |        |    |   + Puntaje
# |        |        |    |   |  +codigo cliente: NO INTERESA
# |        |        |    |   |  |          +sitio
# |        |        |    |   |  |          | +modalidad: NO INTERESA
# |        |        |    |   |  |          | | +persona: NO INTERESA
# |        |        |    |   |  |          | | |
#ESTEPANO,20110909,1022,E03,12,30354444882,E,P,II

	my $cumple_encuestadores = 0;
	my $cumple_numeros = 0;
	my $cumple_sitios = 0;
	my $cumple_codigos = 0;

	if( @criterio_encuestadores == 0 ) {
		$cumple_encuestadores = 1;
	} else {
		foreach (@criterio_encuestadores) {
			if ($registro{'encuestador'} =~ $_ ) {  # @TODO: USAR ANCHORS
				$cumple_encuestadores = 1;
				last;
			}
		}
	}

	if( @criterio_sitios == 0 ) {
		$cumple_sitios = 1;
	} else {
		foreach (@criterio_encuestadores) {
			if ($registro{'sitio'} =~ $_ ) { # @TODO: USAR ANCHORS
				$cumple_sitios = 1;
				last;
			}
		}
	}

	if( @criterio_codigos == 0 ) {
		$cumple_codigos = 1;
	} else {
		foreach (@criterio_codigos) {
			if ($registro{'codigo'} =~ $_ ) { # @TODO: USAR ANCHORS
				$cumple_sitios = 1;
				last;
			}
		}
	}

	if( @criterio_numeros == 0 ) {
		$cumple_numeros = 1;
	} elsif ( @criterio_numeros == 0 ) {
		if ($registro{'numero'} =~ $criterio_numeros[0] ) { # @TODO: USAR ANCHORS
			$cumple_numeros = 1;
		}
	} else {
		if ( $registro{'numero'} >= $criterio_numeros[0] && $registro{'numero'} <= $criterio_numeros[1]) {
			$cumple_numeros = 1;
		}
	}

	#controlar que $registro cumpla el criterio
	if ( $cumple_encuestadores
		&& $cumple_numeros
		&& $cumple_sitios
		&& $cumple_codigos
	) {
		Util::imprimir_hash( %registro );
	}
	
}
close(ARCHIVO);






# 
# -c 
# -e
# -h
# 
# outdir=ya
# reportname=fecha:hora.txt
